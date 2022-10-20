import 'package:flutter/cupertino.dart';

abstract class FocusUtil {
  static void handleFocus(Function() pFunction) {
    _FocusHandler(pFunction);
  }
}

class _FocusHandler {
  final Function() pFunction;

  final FocusNode? currentObjectFocused;

  _FocusHandler(this.pFunction) : currentObjectFocused = FocusManager.instance.primaryFocus {
    if (currentObjectFocused == null || currentObjectFocused!.parent == null) {
      pFunction.call();
    } else {
      currentObjectFocused!.addListener(handle);
      currentObjectFocused!.unfocus();
    }
  }

  void handle() {
    pFunction.call();

    currentObjectFocused!.removeListener(handle);
  }
}
