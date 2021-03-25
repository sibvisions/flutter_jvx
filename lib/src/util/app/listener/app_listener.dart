class AppListener {
  List<Function> _afterStartupListeners = <Function>[];
  List<Function> _onUpdateListeners = <Function>[];

  AppListener addAfterStartupListener(Function afterStartupListener) {
    _afterStartupListeners.add(afterStartupListener);

    return this;
  }

  AppListener addOnUpdateListener(Function onUpdateListener) {
    _onUpdateListeners.add(onUpdateListener);

    return this;
  }

  AppListener removeAfterStartupListener(Function afterStartupListener) {
    _afterStartupListeners.remove(afterStartupListener);

    return this;
  }

  AppListener removeOnUpdateListener(Function onUpdateListener) {
    _onUpdateListeners.remove(onUpdateListener);

    return this;
  }

  void fireAfterStartupListener(dynamic callBackParameter) {
    if (_afterStartupListeners.isNotEmpty) {
      for (final listener in _afterStartupListeners) {
        listener(callBackParameter);
      }
    }
  }

  void fireOnUpdateListener(dynamic callBackParameter) {
    if (_onUpdateListeners.isNotEmpty) {
      for (final listener in _onUpdateListeners) {
        listener(callBackParameter);
      }
    }
  }

  List<Function> get afterStartupListeners {
    return _afterStartupListeners;
  }

  List<Function> get onUpdateListeners {
    return _onUpdateListeners;
  }
}
