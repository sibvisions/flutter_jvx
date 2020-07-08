abstract class AppListener {
  List<Function> _afterStartupListeners = <Function>[];

  AppListener addAfterStartupListener(Function afterStartupListener){
    _afterStartupListeners.add(afterStartupListener);

    return this;
  }

  AppListener removeAfterStartupListener(Function afterStartupListener){
    _afterStartupListeners.remove(afterStartupListener);

    return this;
  }

  void fireAfterStartupListener(dynamic callBackParameter) {
    if (_afterStartupListeners != null && _afterStartupListeners.isNotEmpty) {
      for (final listener in _afterStartupListeners) {
        listener(callBackParameter);
      }
    }
  }

  List<Function> get afterStartupListeners {
    return _afterStartupListeners;
  }
}
