import 'dart:async';
import 'package:flutter/widgets.dart';

import '../../flutter_ui.dart';

class ActiveObserver with WidgetsBindingObserver {
  Completer<void>? _completer;
  Timer? _timeoutTimer;

  Future<void> waitUntilActiveOrTimeout(Duration timeout) async {
    // in case, app is already active
    if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      FlutterUI.logUI.d("ActiveObserver not started because: Already active");
      return;
    }
    else {
      WidgetsBinding.instance.addObserver(this);

      _completer = Completer<void>();

      // Timeout-Fallback
      _timeoutTimer = Timer(timeout, () {
        _complete('Timeout');
      });

      return _completer!.future;
    }
  }

  void _complete(String reason) {
    if (_completer != null && !_completer!.isCompleted) {
      WidgetsBinding.instance.removeObserver(this);

      _completer!.complete();
      _timeoutTimer?.cancel();

      FlutterUI.logUI.d("ActiveObserver completed: $reason");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _complete('App resumed');
    }
  }

}
