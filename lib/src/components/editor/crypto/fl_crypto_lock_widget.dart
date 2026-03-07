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
import '../../../util/icon_util.dart';
import '../../base_wrapper/fl_stateless_widget.dart';
import '../cell_editor/fl_text_cell_editor.dart';
import '../cell_editor/i_cell_editor.dart';
import '../password_field/fl_password_field_widget.dart';
import '../text_field/fl_text_field_widget.dart';

class FlCryptoLockWidget extends FlStatelessWidget<FlComponentModel> {
  final ICellEditor cellEditor;

  const FlCryptoLockWidget({
    super.key,
    required super.model,
    required this.cellEditor});

  @override
  Widget build(BuildContext context) {
    FlTextFieldModel? editModel;

    if (cellEditor is FlTextCellEditor) {
      if (cellEditor.model.contentType == FlTextCellEditor.TEXT_PLAIN_PASSWORD) {
        editModel = FlPasswordFieldModel();
      }
    }

    editModel ??= FlTextFieldModel();
    editModel.isEnabled = false;
    editModel.isEditable = false;
    editModel.styles.addAll(super.model.styles);
    editModel.styles.add("${FlComponentModel.STYLE_PREFIX_ICON}${IconUtil.PREFIX_FONT_AWESOME}keycdn_#607D8B99");
    editModel.styles.add("${FlComponentModel.STYLE_BORDER_COLOR_DISABLED}#607D8BCC");
    editModel.styles.add("${FlComponentModel.STYLE_TEXT_COLOR_DISABLED}#607D8B99");

    if (editModel is FlPasswordFieldModel) {
      return FlPasswordWidget(
          model: editModel,
          valueChanged: _doNotChange,
          endEditing: _doNotEdit,
          focusNode: FocusNode(),
          textController: TextEditingController(text: FlutterUI.translate("Encrypted")),
          onlyPlainText: true,
          hideSuffixIcons: true,
          hidePasswordStrengthLabel: true,
          hidePasswordStrengthColor: true
      );
    }
    else {
      return FlTextFieldWidget(
        model: editModel,
        valueChanged: _doNotChange,
        endEditing: _doNotEdit,
        focusNode: FocusNode(),
        textController: TextEditingController(text: FlutterUI.translate("Encrypted")),
        hideSuffixIcons: true
      );
    }
  }

  static void _doNotChange(String value, [bool? hasFocus]) {}
  static void _doNotEdit(String value, [String? action]) {}
}
