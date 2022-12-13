/* Copyright 2022 SIB Visions GmbH
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
import '../../../model/component/editor/text_area/fl_text_area_model.dart';
import 'fl_text_area_widget.dart';

class FlTextAreaDialog extends StatefulWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  static const Object CANCEL_OBJECT = Object();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final TextEditingController textController;

  final FocusNode focusNode;

  final FlTextAreaModel model;

  /// The callback notifying that the editor value has changed.
  final Function(String) valueChanged;

  /// The callback notifying that the editor value has changed and the editing was completed.
  final Function(String) endEditing;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlTextAreaDialog({
    super.key,
    required this.textController,
    required this.focusNode,
    required this.model,
    required this.valueChanged,
    required this.endEditing,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlTextAreaDialogState createState() => FlTextAreaDialogState();
}

class FlTextAreaDialogState extends State<FlTextAreaDialog> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    List<Widget> listBottomButtons = [];

    listBottomButtons.add(
      Flexible(
        flex: 1,
        child: Align(
          alignment: Alignment.centerLeft,
          child: ElevatedButton(
            child: Text(
              FlutterUI.translate("Cancel"),
            ),
            onPressed: () {
              Navigator.of(context).pop(FlTextAreaDialog.CANCEL_OBJECT);
            },
          ),
        ),
      ),
    );

    listBottomButtons.add(
      Flexible(
        flex: 1,
        child: Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            child: Text(
              FlutterUI.translate("OK"),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );

    widget.focusNode.requestFocus();
    return Dialog(
      insetPadding: const EdgeInsets.all(0.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: FlTextAreaWidget(
                model: widget.model,
                textController: widget.textController,
                focusNode: widget.focusNode,
                valueChanged: (value) {
                  widget.valueChanged(value);
                  // Set state to update the textfield widget.
                  setState(() {});
                },
                endEditing: (value) {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Row(
              children: listBottomButtons,
            ),
          ],
        ),
      ),
    );
  }
}
