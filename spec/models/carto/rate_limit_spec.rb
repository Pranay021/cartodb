# encoding: utf-8

require 'spec_helper_min'
require 'support/helpers'

describe Carto::RateLimit do
  include CartoDB::Factories

  before :each do
    User.any_instance.stubs(:save_rate_limits).returns(true)
    @user = FactoryGirl.create(:valid_user)
    @rate_limit = Carto::RateLimit.create!(maps_anonymous: [0, 1, 2],
                                           maps_static: [3, 4, 5],
                                           maps_static_named: [6, 7, 8],
                                           maps_dataview: [9, 10, 11],
                                           maps_dataview_search: [12, 13, 14],
                                           maps_analysis: [18, 19, 20],
                                           maps_tile: [1, 2, 17, 30, 32, 34],
                                           maps_attributes: [21, 22, 23],
                                           maps_named_list: [24, 25, 26],
                                           maps_named_create: [27, 28, 29],
                                           maps_named_get: [30, 31, 32],
                                           maps_named: [33, 34, 35],
                                           maps_named_update: [36, 37, 38],
                                           maps_named_delete: [39, 40, 41],
                                           maps_named_tiles: [10, 11, 12],
                                           sql_query: [13, 14, 15],
                                           sql_query_format: [16, 17, 18],
                                           sql_job_create: [19, 110, 111],
                                           sql_job_get: [6, 7, 8],
                                           sql_job_delete: [0, 1, 2])
  end

  after :each do
    User.any_instance.unstub(:save_rate_limits)
    @rate_limit.destroy if @rate_limit
    @rate_limit2.destroy if @rate_limit2
    @user.destroy if @user
  end

  describe '#create' do
    it 'is persisted correctly to database' do
      rate_limit = Carto::RateLimit.find(@rate_limit.id)

      rate_limit.maps_anonymous.first.max_burst.should eq 0
      rate_limit.maps_anonymous.first.count_per_period.should eq 1
      rate_limit.maps_anonymous.first.period.should eq 2

      rate_limit.maps_anonymous.first.to_array.should eq [0, 1, 2]
      rate_limit.maps_static.first.to_array.should eq [3, 4, 5]
      rate_limit.maps_static_named.first.to_array.should eq [6, 7, 8]
      rate_limit.maps_dataview.first.to_array.should eq [9, 10, 11]
      rate_limit.maps_dataview_search.first.to_array.should eq [12, 13, 14]
      rate_limit.maps_analysis.first.to_array.should eq [18, 19, 20]

      rate_limit.maps_tile.length.should eq 2
      rate_limit.maps_tile.to_redis_array.should eq [1, 2, 17, 30, 32, 34]

      rate_limit.maps_attributes.first.to_array.should eq [21, 22, 23]
      rate_limit.maps_named_list.first.to_array.should eq [24, 25, 26]
      rate_limit.maps_named_create.first.to_array.should eq [27, 28, 29]
      rate_limit.maps_named_get.first.to_array.should eq [30, 31, 32]
      rate_limit.maps_named.first.to_array.should eq [33, 34, 35]
      rate_limit.maps_named_update.first.to_array.should eq [36, 37, 38]
      rate_limit.maps_named_delete.first.to_array.should eq [39, 40, 41]
      rate_limit.maps_named_tiles.first.to_array.should eq [10, 11, 12]
      rate_limit.sql_query.first.to_array.should eq [13, 14, 15]
      rate_limit.sql_query_format.first.to_array.should eq [16, 17, 18]
      rate_limit.sql_job_create.first.to_array.should eq [19, 110, 111]
      rate_limit.sql_job_get.first.to_array.should eq [6, 7, 8]
      rate_limit.sql_job_delete.first.to_array.should eq [0, 1, 2]
    end

    it 'updates a rate_limit' do
      rate_limit = Carto::RateLimit.find(@rate_limit.id)

      rate_limit.maps_anonymous.first.max_burst = 1
      rate_limit.maps_anonymous.first.count_per_period = 2
      rate_limit.maps_anonymous.first.period = 3

      rate_limit.maps_tile.each do |r|
        r.max_burst += 1
        r.count_per_period += 1
        r.period += 1
      end

      rate_limit.save

      rate_limit = Carto::RateLimit.find(@rate_limit.id)

      rate_limit.maps_anonymous.first.max_burst.should eq 1
      rate_limit.maps_anonymous.first.count_per_period.should eq 2
      rate_limit.maps_anonymous.first.period.should eq 3

      rate_limit.maps_tile.first.max_burst.should eq 2
      rate_limit.maps_tile.first.count_per_period.should eq 3
      rate_limit.maps_tile.first.period.should eq 18

      rate_limit.maps_tile.second.max_burst.should eq 31
      rate_limit.maps_tile.second.count_per_period.should eq 33
      rate_limit.maps_tile.second.period.should eq 35
    end

    it 'is persisted correctly to redis' do
      map_prefix = "limits:rate:store:#{@user.username}:maps:"
      sql_prefix = "limits:rate:store:#{@user.username}:sql:"

      $limits_metadata.LRANGE("#{map_prefix}anonymous", 0, 2).should == []
      $limits_metadata.LRANGE("#{map_prefix}static", 0, 2).should == []
      $limits_metadata.LRANGE("#{map_prefix}static_named", 0, 2).should == []
      $limits_metadata.LRANGE("#{map_prefix}dataview", 0, 2).should == []
      $limits_metadata.LRANGE("#{map_prefix}dataview_search", 0, 2).should == []
      $limits_metadata.LRANGE("#{map_prefix}analysis", 0, 2).should == []
      $limits_metadata.LRANGE("#{map_prefix}tile", 0, 5).should == []
      $limits_metadata.LRANGE("#{map_prefix}attributes", 0, 2).should == []
      $limits_metadata.LRANGE("#{map_prefix}named_list", 0, 2).should == []
      $limits_metadata.LRANGE("#{map_prefix}named_create", 0, 2).should == []
      $limits_metadata.LRANGE("#{map_prefix}named_get", 0, 2).should == []
      $limits_metadata.LRANGE("#{map_prefix}named", 0, 2).should == []
      $limits_metadata.LRANGE("#{map_prefix}named_update", 0, 2).should == []
      $limits_metadata.LRANGE("#{map_prefix}named_delete", 0, 2).should == []
      $limits_metadata.LRANGE("#{map_prefix}named_tiles", 0, 2).should == []
      $limits_metadata.LRANGE("#{sql_prefix}query", 0, 2).should == []
      $limits_metadata.LRANGE("#{sql_prefix}query_format", 0, 2).should == []
      $limits_metadata.LRANGE("#{sql_prefix}job_create", 0, 2).should == []
      $limits_metadata.LRANGE("#{sql_prefix}job_get", 0, 2).should == []
      $limits_metadata.LRANGE("#{sql_prefix}job_delete", 0, 2).should == []

      @rate_limit.save_to_redis(@user)

      $limits_metadata.LRANGE("#{map_prefix}anonymous", 0, 2).should == ["0", "1", "2"]
      $limits_metadata.LRANGE("#{map_prefix}static", 0, 2).should == ["3", "4", "5"]
      $limits_metadata.LRANGE("#{map_prefix}static_named", 0, 2).should == ["6", "7", "8"]
      $limits_metadata.LRANGE("#{map_prefix}dataview", 0, 2).should == ["9", "10", "11"]
      $limits_metadata.LRANGE("#{map_prefix}dataview_search", 0, 2).should == ["12", "13", "14"]
      $limits_metadata.LRANGE("#{map_prefix}analysis", 0, 2).should == ["18", "19", "20"]
      $limits_metadata.LRANGE("#{map_prefix}tile", 0, 5).should == ["1", "2", "17", "30", "32", "34"]
      $limits_metadata.LRANGE("#{map_prefix}attributes", 0, 2).should == ["21", "22", "23"]
      $limits_metadata.LRANGE("#{map_prefix}named_list", 0, 2).should == ["24", "25", "26"]
      $limits_metadata.LRANGE("#{map_prefix}named_create", 0, 2).should == ["27", "28", "29"]
      $limits_metadata.LRANGE("#{map_prefix}named_get", 0, 2).should == ["30", "31", "32"]
      $limits_metadata.LRANGE("#{map_prefix}named", 0, 2).should == ["33", "34", "35"]
      $limits_metadata.LRANGE("#{map_prefix}named_update", 0, 2).should == ["36", "37", "38"]
      $limits_metadata.LRANGE("#{map_prefix}named_delete", 0, 2).should == ["39", "40", "41"]
      $limits_metadata.LRANGE("#{map_prefix}named_tiles", 0, 2).should == ["10", "11", "12"]
      $limits_metadata.LRANGE("#{sql_prefix}query", 0, 2).should == ["13", "14", "15"]
      $limits_metadata.LRANGE("#{sql_prefix}query_format", 0, 2).should == ["16", "17", "18"]
      $limits_metadata.LRANGE("#{sql_prefix}job_create", 0, 2).should == ["19", "110", "111"]
      $limits_metadata.LRANGE("#{sql_prefix}job_get", 0, 2).should == ["6", "7", "8"]
      $limits_metadata.LRANGE("#{sql_prefix}job_delete", 0, 2).should == ["0", "1", "2"]

      @rate_limit.maps_static.first.max_burst = 4
      @rate_limit.save_to_redis(@user)
      $limits_metadata.LRANGE("#{map_prefix}static", 0, 2).should == ["4", "4", "5"]
    end

    it 'cannot crate a rate_limit with wrong number of rate limits' do
      expect {
        Carto::RateLimit.create!(maps_anonymous: [0, 1],
                                 maps_static: [3, 4, 5],
                                 maps_static_named: [6, 7, 8],
                                 maps_dataview: [9, 10, 11],
                                 maps_dataview_search: [12, 13, 14],
                                 maps_analysis: [18, 19, 20],
                                 maps_tile: [1, 2, 17, 30, 32, 34],
                                 maps_attributes: [21, 22, 23],
                                 maps_named_list: [24, 25, 26],
                                 maps_named_create: [27, 28, 29],
                                 maps_named_get: [30, 31, 32],
                                 maps_named: [33, 34, 35],
                                 maps_named_update: [36, 37, 38],
                                 maps_named_delete: [39, 40, 41],
                                 maps_named_tiles: [10, 11, 12],
                                 sql_query: [13, 14, 15],
                                 sql_query_format: [16, 17, 18],
                                 sql_job_create: [19, 110, 111],
                                 sql_job_get: [6, 7, 8],
                                 sql_job_delete: [0, 1, 2])
      }.to raise_error(/Error: Number of rate limits needs to be multiple of three/)

      expect {
        Carto::RateLimit.create!(maps_anonymous: [0, 1, 2],
                                 maps_static: [3, 4, 5],
                                 maps_static_named: [6, 7, 8],
                                 maps_dataview: [9, 10, 11],
                                 maps_dataview_search: [12, 13, 14],
                                 maps_analysis: [18, 19, 20],
                                 maps_tile: [1, 2, 17, 30],
                                 maps_attributes: [21, 22, 23],
                                 maps_named_list: [24, 25, 26],
                                 maps_named_create: [27, 28, 29],
                                 maps_named_get: [30, 31, 32],
                                 maps_named: [33, 34, 35],
                                 maps_named_update: [36, 37, 38],
                                 maps_named_delete: [39, 40, 41],
                                 maps_named_tiles: [10, 11, 12],
                                 sql_query: [13, 14, 15],
                                 sql_query_format: [16, 17, 18],
                                 sql_job_create: [19, 110, 111],
                                 sql_job_get: [6, 7, 8],
                                 sql_job_delete: [0, 1, 2])
      }.to raise_error(/Error: Number of rate limits needs to be multiple of three/)
    end

    it 'creates empty rate limits if endpoint is set to nil or does not exist' do
      expect {
        @rate_limit2 = Carto::RateLimit.create!(maps_anonymous: nil,
                                                maps_static_named: [6, 7, 8],
                                                maps_dataview: [9, 10, 11],
                                                maps_dataview_search: [12, 13, 14],
                                                maps_analysis: [18, 19, 20],
                                                maps_tile: [1, 2, 17],
                                                maps_attributes: [21, 22, 23],
                                                maps_named_list: [24, 25, 26],
                                                maps_named_create: [27, 28, 29],
                                                maps_named_get: [30, 31, 32],
                                                maps_named: [33, 34, 35],
                                                maps_named_update: [36, 37, 38],
                                                maps_named_delete: [39, 40, 41],
                                                maps_named_tiles: [10, 11, 12],
                                                sql_query: [13, 14, 15],
                                                sql_query_format: [16, 17, 18],
                                                sql_job_create: [19, 110, 111],
                                                sql_job_get: [6, 7, 8],
                                                sql_job_delete: [0, 1, 2])
      }.to_not raise_error

      @rate_limit2 = Carto::RateLimit.find(@rate_limit2.id)
      @rate_limit2.maps_anonymous.should be_empty
      @rate_limit2.maps_static.should be_empty
    end

    it 'correctly creates rate limits if any endpoint values are empty' do
      expect {
        @rate_limit2 = Carto::RateLimit.create!(maps_anonymous: [],
                                                maps_static: [3, 4, 5],
                                                maps_static_named: [6, 7, 8],
                                                maps_dataview: [9, 10, 11],
                                                maps_dataview_search: [12, 13, 14],
                                                maps_analysis: [18, 19, 20],
                                                maps_tile: [1, 2, 17],
                                                maps_attributes: [21, 22, 23],
                                                maps_named_list: [24, 25, 26],
                                                maps_named_create: [27, 28, 29],
                                                maps_named_get: [30, 31, 32],
                                                maps_named: [33, 34, 35],
                                                maps_named_update: [36, 37, 38],
                                                maps_named_delete: [39, 40, 41],
                                                maps_named_tiles: [10, 11, 12],
                                                sql_query: [13, 14, 15],
                                                sql_query_format: [16, 17, 18],
                                                sql_job_create: [19, 110, 111],
                                                sql_job_get: [6, 7, 8],
                                                sql_job_delete: [0, 1, 2])
      }.to_not raise_error

      @rate_limit2 = Carto::RateLimit.find(@rate_limit2.id)
      @rate_limit2.maps_anonymous.should be_empty
    end
  end
end
