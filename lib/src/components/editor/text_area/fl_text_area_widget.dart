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

import 'dart:math';

import 'package:flutter/material.dart';

import '../../../flutter_ui.dart';
import '../../../mask/frame/frame.dart';
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
  bool get isExpandend => true;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: !model.isReadOnly && canShowDialog ? _openDialogEditor : null,
      child: super.build(context),
    );
  }

  @override
  Widget? createSuffixIcon() {
    return Container(
      height: double.infinity,

      /// -4 => The editable text inside a textfield is somehow 8 pixels bigger.
      padding: EdgeInsets.only(
          top: contentPadding.top - 4 - ((clickableClearArea - iconSize) / 2),
          bottom: contentPadding.bottom - 4 - ((clickableClearArea - iconSize) / 2)),
      child: super.createSuffixIcon(),
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
        } else {
          endEditing(value);
        }
      }
    });
  }

  static Size calculateTextAreaHight(Size pCalculatedSize, int pRows) {
    double height = pCalculatedSize.height;

    EdgeInsets paddings = Frame.isWebFrame() ? FlTextFieldWidget.WEBFRAME_PADDING : FlTextFieldWidget.MOBILE_PADDING;

    /// -4 => The editable text inside a textfield is somehow 8 pixels bigger.
    paddings -= const EdgeInsets.fromLTRB(0, 4, 0, 4);

    if (pRows > 1) {
      height -= paddings.vertical;
      height *= pRows;
      height += paddings.vertical;
    }

    return Size(pCalculatedSize.width, max(pCalculatedSize.height, height));
  }
}
