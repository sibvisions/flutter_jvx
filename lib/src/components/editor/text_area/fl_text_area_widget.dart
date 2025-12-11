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
import '../../../model/layout/alignments.dart';
import '../text_field/fl_text_field_widget.dart';
import 'fl_text_area_dialog.dart';

class FlTextAreaWidget<T extends FlTextAreaModel> extends FlTextFieldWidget<T> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final bool canShowDialog;

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
    super.isMandatory,
    this.canShowDialog = true,
    super.hideClearIcon,
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
  CrossAxisAlignment get iconCrossAxisAlignment {
    if (model.verticalAlignment == VerticalAlignment.TOP) {
      return CrossAxisAlignment.start;
    } else if (model.verticalAlignment == VerticalAlignment.BOTTOM) {
      return CrossAxisAlignment.end;
    }

    return CrossAxisAlignment.center;
  }

  @override
  bool get isExpanded => true;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    if (!model.isReadOnly && canShowDialog) {
      //Stack instead of full GestureDetector, to avoid delay between tap and double tap
      return Stack(
        children: [
          super.build(context),
          Positioned.fill(
            right: FlTextFieldWidget.iconAreaSize + iconsPadding.left + iconsPadding.right,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onDoubleTap: _openDialogEditor,
              child: Container(), // hidden
            ),
          ),
        ],
      );
    }
    else {
      return super.build(context);
    }
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
          model: model,
          value: textController.value,
          inputFormatters: inputFormatters,
          isMandatory: isMandatory,
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
          valueChanged(value);
        } else {
          endEditing(value);
          focusNode.requestFocus();
        }
      }
    });
  }

  static double calculateTextAreaHeight(FlTextAreaModel pModel) {
    double height = FlTextFieldWidget.TEXT_FIELD_HEIGHT;

    if (pModel.rows > 1) {
      EdgeInsets paddings = FlTextFieldWidget.TEXT_FIELD_PADDING(pModel.createTextStyle());
      height -= paddings.vertical;
      height *= pModel.rows;
      height += paddings.vertical;
    }

    return height;
  }
}
