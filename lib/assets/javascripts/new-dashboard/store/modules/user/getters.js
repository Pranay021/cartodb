export function canCreateDatasets (state) {
  if (!state.remaining_byte_quota || state.remaining_byte_quota <= 0) {
    return false;
  }

  return hasCreateDatasetsFeature(state);
}

export function hasCreateDatasetsFeature (state) {
  return isBuilder(state);
}

export function isBuilder (state) {
  return !isViewer(state);
}

export function isViewer (state) {
  return state.viewer === true;
}

export function hasEngine (state) {
  return state.actions.engine_enabled === true;
}

export function isNotificationVisible (state) {
  return state.notification && state.showNotification;
}

export function userNotification (state) {
  return state.notification ? state.notification : null;
}
