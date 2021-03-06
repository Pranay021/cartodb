<template>
  <div class="header">
    <div class="container">
      <ul class="breadcrumbs">
        <li class="breadcrumbs__item"
          :class="{ 'current' : isCurrentStep(index) }"
          v-for="(stepName, index) in stepNames" :key="stepName">
          <a :class="stepClass(index)" href="javascript:void 0" @click="goToStep(index)">
            <span class="breadcrumbs__checkpoint" :class="{ 'current' : isCurrentStep(index) }">
              <span class="breadcrumbs__text u-hideMobile">{{ stepName }}</span>
            </span>
          </a>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Header',
  props: {
    stepNames: Array,
    currentStep: Number
  },
  methods: {
    isCurrentStep (index) {
      return index + 1 === this.currentStep;
    },
    goToStep (stepNumber) {
      this.$emit('goToStep', stepNumber + 1);
    },
    stepClass (stepNumber) {
      return `step-${stepNumber + 1}`;
    }
  }
};
</script>

<style scoped lang="scss">
@import 'new-dashboard/styles/variables';

$timeline__border-width: 1px;
$timeline__border-color: #DDD;
$timeline__border-transition: 0.25s;
$bullet__transition: 0.12s;
$bullet__border-color: #D3E6FA;
$transition__timing-function: cubic-bezier(0.4, 0.01, 0.165, 0.99);

.header {
  display: block;
  padding-top: 2.375em;
  background: $white;
}

.container {
  width: 100%;
}

.breadcrumbs {
  display: flex;
  justify-content: space-between;
  max-width: 90%;
  margin: 0 auto 1.5em;

  &__item {
    position: relative;
    width: 100%;
    height: 36px;

    &:not(:last-child) {
      border-top: $timeline__border-width solid $primary-color;
    }

    &:last-child {
      width: 0;
      border-top: $timeline__border-width solid transparent;
    }

    &::after {
      content: '';
      display: block;
      position: absolute;
      top: -$timeline__border-width;
      right: 0;
      width: 0%;
      transition: width $timeline__border-transition $transition__timing-function;
      border-top: $timeline__border-width solid $timeline__border-color;
    }

    &.current {
      &::after {
        content: '';
        display: block;
        position: absolute;
        top: -$timeline__border-width;
        right: 0;
        width: 100%;
        transition: width $timeline__border-transition $transition__timing-function;
        border-top: $timeline__border-width solid $timeline__border-color;
      }

      &:last-child {
        border-color: transparent;
      }

      & ~ .breadcrumbs__item {
        border-color: $timeline__border-color;

        &::after {
          content: '';
          display: block;
          position: absolute;
          top: -$timeline__border-width;
          right: 0;
          width: 100%;
          transition: none;
          border-top: $timeline__border-width solid $timeline__border-color;
        }

        &:last-child {
          border-color: transparent;
        }
      }

      & ~ .breadcrumbs__item .breadcrumbs__checkpoint {
        top: -4px;
        left: -4px;
        width: 7px;
        height: 7px;
        background: $timeline__border-color;
      }

      & ~ .breadcrumbs__item .breadcrumbs__text {
        color: $text__color--secondary;
      }
    }
  }

  &__text {
    position: absolute;
    top: 24px;
    left: 50%;
    transform: translateX(-50%);
    color: $text__color;
    font-size: 0.75em;
    white-space: nowrap;
  }

  &__checkpoint {
    display: block;
    position: absolute;
    z-index: 1;
    top: -4px;
    left: -4px;
    width: 7px;
    height: 7px;
    transition: all $bullet__transition $transition__timing-function;
    border-radius: 50%;
    background: $primary-color;

    &.current {
      transition: all $bullet__transition $transition__timing-function;
      transition-delay: $timeline__border-transition;
      box-shadow: 0 0 0 6px $bullet__border-color;

      .breadcrumbs__text {
        transition: all $bullet__transition $transition__timing-function;
        color: $text__color;
        font-weight: 600;
      }
    }
  }
}
</style>
