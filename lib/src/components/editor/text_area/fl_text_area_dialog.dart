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
import 'package:flutter/services.dart';

import '../../../flutter_ui.dart';
import '../../../model/component/fl_component_model.dart';
import 'fl_text_area_widget.dart';

class FlTextAreaDialog extends StatefulWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final FlTextAreaModel model;

  final bool isMandatory;

  final List<TextInputFormatter>? inputFormatters;

  final TextEditingValue value;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlTextAreaDialog({
    super.key,
    required this.model,
    required this.value,
    this.inputFormatters,
    this.isMandatory = false,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlTextAreaDialogState createState() => FlTextAreaDialogState();
}

class FlTextAreaDialogState extends State<FlTextAreaDialog> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final TextEditingController textController = TextEditingController();

  final FocusNode focusNode = FocusNode();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    super.initState();
    textController.value = widget.value;

    focusNode.requestFocus();
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
              Navigator.of(context).pop(textController.text);
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
                textController: textController,
                focusNode: focusNode,
                inputFormatters: widget.inputFormatters,
                isMandatory: widget.isMandatory,
                valueChanged: (value) {
                  // Set state to update the textfield widget.
                  setState(() {});
                },
                canShowDialog: false,
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
    focusNode.dispose();
    textController.dispose();
    super.dispose();
  }
}
