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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../flutter_ui.dart';
import 'webview_dialog_widget.dart';

class WebViewDialogService {
  static final GlobalKey<WebViewDialogState> webViewKey = GlobalKey<WebViewDialogState>();

  static OverlayEntry? _entry;

  static Completer<void>? _closeCompleter;


  static Future<void> show({
    String? title,
    bool dismissible = false,
    required WebViewController controller}
  ) async {
    _entry?.remove(); //to be sure
    _closeCompleter?.complete();

    _closeCompleter = Completer<void>();

    _entry = OverlayEntry(
      builder: (context) {

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
          canPop: dismissible,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;

            hide();
          },
          child: Stack(
            children: [
              barrier,
                SafeArea(
                  child: WebViewDialogWidget(
                    key: webViewKey,
                    title: title,
                    dismissible: dismissible,
                    controller: controller
                  )
                )

            ],
          ),
        );
      },
    );

    rootNavigatorKey.currentState?.insert(_entry!);

    return _closeCompleter!.future;
  }

  static Future<void> hide() async {
    await webViewKey.currentState?.reverse();

    _entry?.remove();
    _entry = null;

    _closeCompleter?.complete();
    _closeCompleter = null;
  }

  static bool isVisible() {
    return _entry != null;
  }

}