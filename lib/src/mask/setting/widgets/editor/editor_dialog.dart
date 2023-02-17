/* 
 * Copyright 2022 SIB Visions GmbH
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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../flutter_ui.dart';

typedef EditorBuilder = Widget Function(
  BuildContext context,
  Function() onConfirm,
);

class EditorDialog extends StatelessWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The editor widget to be shown
  final EditorBuilder editorBuilder;

  final TextEditingController controller;

  /// Icon to be displayed at the top of the dialog
  final FaIcon? titleIcon;

  /// Title of the editor, will be show above the editor
  final String titleText;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const EditorDialog({
    super.key,
    required this.titleText,
    required this.editorBuilder,
    required this.controller,
    this.titleIcon,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: _createTitle(context),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: editorBuilder.call(context, () => Navigator.pop(context, true)),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: _closeButtons(context),
            ),
          ],
        ));
  }

  /// Returns the
  Widget _closeButtons(BuildContext context) {
    TextStyle style = const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(FlutterUI.translate("Cancel"), style: style),
        ),
        const SizedBox(width: 20),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(FlutterUI.translate("Confirm"), style: style),
        ),
      ],
    );
  }

  /// Returns the title Widget of the editor
  /// containing the [titleIcon] and [titleText]
  Widget _createTitle(BuildContext context) {
    return Stack(
      children: [
        if (titleIcon != null) titleIcon!,
        Center(
          child: Text(
            titleText,
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
        ),
      ],
    );
  }
}
