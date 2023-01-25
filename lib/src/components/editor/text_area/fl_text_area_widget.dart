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
import '../text_field/fl_text_field_widget.dart';
import 'fl_text_area_dialog.dart';

class FlTextAreaWidget<T extends FlTextAreaModel> extends FlTextFieldWidget<T> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlTextAreaWidget({
    super.key,
    required super.model,
    required super.valueChanged,
    required super.endEditing,
    required super.focusNode,
    required super.textController,
    super.inputFormatters,
    super.inTable,
    super.isMandatory,
  }) : super(
          keyboardType: TextInputType.multiline,
        );

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden widget defaults
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  int? get minLines => null;

  @override
  int? get maxLines => null;

  @override
  bool get isExpandend => true;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: model.isReadOnly ? null : _openDialogEditor,
      child: super.build(context),
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void _openDialogEditor() {
    bool hadFocus = focusNode.hasPrimaryFocus;
    showDialog(
      context: FlutterUI.getCurrentContext()!,
      builder: (context) {
        return FlTextAreaDialog(
          value: textController.value,
          model: model,
        );
      },
    ).then((value) {
      if (value == null) {
        return;
      }

      if (value != textController.text) {
        if (hadFocus) {
          focusNode.requestFocus();
          textController.text = value;
        } else {
          endEditing(value);
        }
      }
    });
  }
}
