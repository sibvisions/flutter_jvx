/*
 * Copyright 2026 SIB Visions GmbH
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

import 'package:flutter/material.dart';

import '../../../flutter_ui.dart';
import 'progress_dialog_widget.dart';

class ProgressDialogService {
  static OverlayEntry? _entry;
  static final GlobalKey<ProgressDialogState> dialogKey = GlobalKey<ProgressDialogState>();

  static void show(Config config) {
    _entry?.remove(); //to be sure

    _entry = OverlayEntry(
      builder: (context) {

        bool dismissible = config.barrierDismissible ?? false;

        ProgressDialogState? state = dialogKey.currentState;
        if (state != null) {
          dismissible = state.isDismissible();
        }

        Widget barrier = Container(color: Colors.black54);

        if (dismissible) {
          barrier = GestureDetector(
              onTap: () async {
                await hide();
              },
              child: barrier
          );
        }

        //PopScope is useless in normal usage because the navigator is behind, so
        //we handle the pop in FlutterUI.didPopRoute.
        //This code here is only for completeness
        return PopScope(
          canPop: !dismissible,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;

            hide();
          },
          child: Stack(
            children: [
              barrier,
              ProgressDialogWidget(
                key: dialogKey,
                config: config,
              )
            ],
          ),
        );
      },
    );

    rootNavigatorKey.currentState?.insert(_entry!);
  }

  static void update(Config config) {
    if (_entry != null) {
      if ((dialogKey.currentState?.isDismissible() ?? false) != (config.barrierDismissible ?? false)) {
        _entry!.markNeedsBuild();
      }
    }

    dialogKey.currentState?.update(config);
  }

  static Future<void> hide() async {
    await dialogKey.currentState?.reverse();

    _entry?.remove();
    _entry = null;
  }

  static bool isVisible() {
    return _entry != null;
  }

  static bool isDismissible() {
    return dialogKey.currentState?.isDismissible() ?? false;
  }
}