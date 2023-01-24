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

import '../../../flutter_ui.dart';
import '../../../model/component/fl_component_model.dart';
import 'fl_text_area_widget.dart';

class FlTextAreaDialog extends StatefulWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  late final TextEditingController textController;

  final FocusNode focusNode = FocusNode();

  final FlTextAreaModel model;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlTextAreaDialog({
    super.key,
    required this.model,
    required TextEditingValue value,
  }) : textController = TextEditingController.fromValue(value);

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
  void initState() {
    super.initState();

    widget.focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> listBottomButtons = [];

    listBottomButtons.add(
      Flexible(
        flex: 1,
        child: Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            child: Text(
              FlutterUI.translate("Cancel"),
            ),
            onPressed: () {
              Navigator.of(context).pop();
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
          child: TextButton(
            child: Text(
              FlutterUI.translate("OK"),
            ),
            onPressed: () {
              Navigator.of(context).pop(widget.textController.text);
            },
          ),
        ),
      ),
    );

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

  @override
  void dispose() {
    widget.focusNode.dispose();
    widget.textController.dispose();
    super.dispose();
  }
}
