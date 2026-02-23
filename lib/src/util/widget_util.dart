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

import '../flutter_ui.dart';

abstract class WidgetUtil {
  static OverlayEntry? _overlayEntry;
  static Completer<dynamic>? _inputCompleter;

  static bool close() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;

      return true;
    }

    return false;
  }

  static void _closeInputIntern(String? token) {
    _overlayEntry?.remove();
    _overlayEntry = null;

    if (_inputCompleter != null && !_inputCompleter!.isCompleted) {
      _inputCompleter!.complete(token);
    }
  }

  static Future<dynamic> showInputDialog(String title, String fieldTitle, bool confirm) async {
    if (_overlayEntry != null) {
      return _inputCompleter!.future;
    }

    _inputCompleter = Completer<dynamic>();

    final TextEditingController valueController = TextEditingController();

    TextEditingController? confirmController;

    if (confirm) {
      confirmController = TextEditingController();
    }

    String? errorText;

    Widget w = StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text(FlutterUI.translate(title)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: valueController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: FlutterUI.translate(fieldTitle),
                ),
              ),
              if (confirm) const SizedBox(height: 12),
              if (confirm) TextField(
                controller: confirmController!,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: FlutterUI.translate("Confirm"),
                  errorText: errorText,
                ),
              ),
            ],
          ),
          actionsPadding: EdgeInsets.only(
            bottom: Theme.of(context).dialogTheme.actionsPadding?.vertical ?? 15,
            left: 10,
            right: 10,
            top: 5
          ),
          actions: [
            Row(
              spacing: 0,
              children: [
                TextButton(
                  onPressed: () => _closeInputIntern(""),
                  child: Text(FlutterUI.translate("Cancel")),
                ),
                Spacer(),
                TextButton(
                  onPressed: () {
                    final token = valueController.text.trim();

                    if (confirm) {
                      final tokenConfirm = confirmController!.text.trim();

                      if (token.isEmpty || tokenConfirm.isEmpty) {
                        setState(() => errorText = FlutterUI.translate("Please enter both fields"));
                        return;
                      }

                      if (token != tokenConfirm) {
                        setState(() => errorText = "Tokens do not match!");
                        return;
                      }
                    }
                    _closeInputIntern(token);
                  },
                  child: Text(FlutterUI.translate("OK")),
                ),
              ],
            ),
          ],
        );
      },
    );

    _overlayEntry = OverlayEntry(
        builder: (context) => Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              ModalBarrier(
                color: Colors.black54,
                dismissible: true,
                onDismiss: () => _closeInputIntern(""),
              ),

              Center(child: w),
            ],
          ),
        )
    );

    rootNavigatorKey.currentState?.insert(_overlayEntry!);

    return _inputCompleter!.future;
  }
}
