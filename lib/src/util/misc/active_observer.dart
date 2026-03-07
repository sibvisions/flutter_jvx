/*
 * Copyright 2025 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

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
