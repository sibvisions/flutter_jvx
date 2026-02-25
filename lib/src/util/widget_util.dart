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

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../components/editor/text_field/fl_text_field_widget.dart';
import '../flutter_ui.dart';
import 'jvx_colors.dart';
import 'widgets/password_strength_indicator.dart';

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

    bool valueHidden = true;
    bool confirmHidden = true;

    Function(void Function())? dialogSetState;

    void onTextChanged() {
      if (dialogSetState != null) {
        dialogSetState!(() {});
      }
    }

    final TextEditingController valueController = TextEditingController();
    valueController.addListener(onTextChanged);

    TextEditingController? confirmController;

    if (confirm) {
      confirmController = TextEditingController();
      confirmController.addListener(onTextChanged);
    }

    String? errorText;

    Widget w = StatefulBuilder(
      builder: (context, setState) {

        dialogSetState ??= setState;

        bool isMatch = confirmController == null || valueController.text == confirmController.text;
        bool hasValue = valueController.text.isNotEmpty;

        bool isOkEnabled = (confirmController == null && valueController.text.isNotEmpty) ||
                           (confirmController != null && confirmController.text.isNotEmpty && valueController.text.isNotEmpty && isMatch);

        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 0,
            children: [
              FaIcon(FontAwesomeIcons.keycdn),
              SizedBox(width: 15),
              Flexible(
                fit: FlexFit.tight,
                child: FittedBox(
                  alignment: AlignmentGeometry.topLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(FlutterUI.translate(title))
                )
              )
            ]
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  maxLines: 1,
                  controller: valueController,
                  obscureText: valueHidden,
                  decoration: InputDecoration(
                    labelText: FlutterUI.translate(fieldTitle),
                    suffixIcon: valueController.text.isNotEmpty
                        ? ExcludeFocus(
                      child: IconButton(
                        tooltip: FlutterUI.translate(valueHidden ? "Show" : "Hide"),
                        icon: Icon(
                          valueHidden ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => setState(() => valueHidden = !valueHidden),
                        color: JVxColors.isLightTheme(context) ? JVxColors.COMPONENT_DISABLED : JVxColors.COMPONENT_DISABLED_LIGHTER,
                        iconSize: FlTextFieldWidget.iconSize,
                      ),
                    )
                        : null,
                  ),
                ),
                if (confirm) const SizedBox(height: 12),
                if (confirm) TextField(
                  maxLines: 1,
                  controller: confirmController!,
                  obscureText: confirmHidden,
                  decoration: InputDecoration(
                    labelText: FlutterUI.translate("Confirm"),
                    errorText: errorText,
                    enabledBorder: hasValue ? (Theme.of(context).inputDecorationTheme.enabledBorder?.copyWith(
                      borderSide: BorderSide(
                        color: isMatch ? Colors.green : Colors.red,
                        width: Theme.of(context).inputDecorationTheme.enabledBorder?.borderSide.width ?? 1.0,
                      ),
                    ) ?? UnderlineInputBorder(borderSide: BorderSide(
                      color: isMatch ? Colors.green : Colors.red,
                      width: Theme.of(context).inputDecorationTheme.enabledBorder?.borderSide.width ?? 1.0,
                    )
                    )) : null,
                    focusedBorder: hasValue ? (Theme.of(context).inputDecorationTheme.focusedBorder?.copyWith(
                      borderSide: BorderSide(
                        color: isMatch ? Colors.green : Colors.red,
                        width: Theme.of(context).inputDecorationTheme.focusedBorder?.borderSide.width ?? 2.0,
                      ),
                    ) ?? UnderlineInputBorder(borderSide: BorderSide(
                      color: isMatch ? Colors.green : Colors.red,
                      width: Theme.of(context).inputDecorationTheme.border?.borderSide.width ?? 2.0,
                    )
                    )) : null,
                    suffixIcon: confirmController.text.isNotEmpty
                        ? ExcludeFocus(
                      child: IconButton(
                        tooltip: FlutterUI.translate(confirmHidden ? "Show" : "Hide"),
                        icon: Icon(
                          confirmHidden ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => setState(() => confirmHidden = !confirmHidden),
                        color: JVxColors.isLightTheme(context) ? JVxColors.COMPONENT_DISABLED : JVxColors.COMPONENT_DISABLED_LIGHTER,
                        iconSize: FlTextFieldWidget.iconSize,
                      ),
                    )
                        : null,
                  ),
                ),
                if (confirm)
                  SizedBox(height: 8),
                if (confirm)
                  PasswordStrengthIndicator(password: confirmController!.text),
              ],
            )
          ),
          actionsPadding: EdgeInsets.only(
            bottom: Theme.of(context).dialogTheme.actionsPadding?.vertical ?? 15,
            left: 10,
            right: 10,
            top: 10
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
                  onPressed: isOkEnabled ? () => _closeInputIntern(valueController.text.trim()) : null,
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

  /// Shows a simple toast message
  static void showToast(BuildContext? context, String message) {
    BuildContext? ctxt = context ?? FlutterUI.getCurrentContext();

    if (ctxt != null && ctxt.mounted) {
      bool light = JVxColors.isLightTheme(context);

      Flushbar flush = Flushbar(
        onTap: (f) => f.dismiss(),
        backgroundColor: light ? Colors.black.withAlpha(180) : Colors.grey.withAlpha(220),
        messageText: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 0,
          children: [
            Icon(Icons.file_download_done, color: light ? JVxColors.DARKER_WHITE : Colors.black87),
            SizedBox(width: 10),
            Text(
              FlutterUI.translate("Copied to clipboard"),
              style: TextStyle(
                color: light ? JVxColors.DARKER_WHITE : Colors.black87
              ),
            ),
          ],
        ),
        flushbarPosition: FlushbarPosition.TOP,
        duration: Duration(seconds: 2),
        margin: EdgeInsets.all(20),
        borderRadius: BorderRadius.circular(15),
      );

      unawaited(flush.show(ctxt));
    }
    else {
      FlutterUI.logUI.e("No context for flushbar available!");
    }
  }

}
