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

import 'package:flutter/cupertino.dart';

import '../../../../flutter_jvx.dart';
import '../../../model/component/editor/cell_editor/fl_check_box_cell_editor_model.dart';
import 'button_cell_editor_styles.dart';
import 'i_cell_editor.dart';

class FlCheckBoxCellEditor extends IFocusableCellEditor<FlCheckBoxModel, FlCheckBoxCellEditorModel, dynamic> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // The focus node of the button which is unused.
  final FocusNode _buttonFocusNode = FocusNode();

  /// The value of the check box.
  dynamic _value;

  FlCheckBoxModel? lastWidgetModel;

  @override
  bool get allowedInTable => model.directCellEditor;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlCheckBoxCellEditor({
    required super.columnDefinition,
    required super.cellEditorJson,
    required super.onValueChange,
    required super.onEndEditing,
    required super.columnName,
    required super.dataProvider,
    super.onFocusChanged,
    super.isInTable,
  }) : super(
          model: FlCheckBoxCellEditorModel(),
        );

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void setValue(dynamic pValue) {
    _value = pValue;
  }

  @override
  Widget createWidget(Map<String, dynamic>? pJson) {
    FlCheckBoxModel widgetModel = createWidgetModel();

    applyEditorJson(widgetModel, pJson);

    bool showButtons = model.isButton || model.styles.any((style) => style == ButtonCellEditorStyles.TOGGLEBUTTON);

    if (showButtons) {
      if (model.isButton && model.selectedValue == null && model.deselectedValue == null) {
        widgetModel.labelModel.text = _value ?? "";
      } else if (cellEditorJson["text"] == null && columnDefinition != null) {
        widgetModel.labelModel.text = columnDefinition!.label;
      } else {
        widgetModel.labelModel.text = cellEditorJson["text"] ?? "";
      }
    }

    lastWidgetModel = widgetModel;

    bool isEditable = true;
    if (pJson?.containsKey(ApiObjectProperty.cellEditorEditable) == true) {
      isEditable = pJson![ApiObjectProperty.cellEditorEditable];
    }

    if (model.isButton) {
      return FlButtonWidget(
        model: widgetModel,
        focusNode: _buttonFocusNode,
        onPress: isEditable ? _onPress : null,
      );
    } else if (model.styles.any((style) => style == ButtonCellEditorStyles.RADIOBUTTON)) {
      return FlRadioButtonWidget(
        model: widgetModel,
        focusNode: _buttonFocusNode,
        radioFocusNode: focusNode,
        onPress: isEditable ? _onPress : null,
      );
    } else if (model.styles.any((style) => style == ButtonCellEditorStyles.TOGGLEBUTTON)) {
      return FlToggleButtonWidget(
        model: widgetModel,
        focusNode: _buttonFocusNode,
        onPress: isEditable ? _onPress : null,
      );
    }

    return FlCheckBoxWidget(
      radioFocusNode: focusNode,
      focusNode: _buttonFocusNode,
      model: widgetModel,
      onPress: isEditable ? _onPress : null,
    );
  }

  @override
  createWidgetModel() {
    FlCheckBoxModel widgetModel = FlCheckBoxModel();

    widgetModel.labelModel.text = model.text;
    widgetModel.selected = model.selectedValue == _value;
    widgetModel.imageName = model.imageName;

    return widgetModel;
  }

  @override
  Future<dynamic> getValue() async {
    return _value;
  }

  @override
  void dispose() {
    _buttonFocusNode.dispose();
    super.dispose();
  }

  @override
  String formatValue(dynamic pValue) {
    return pValue?.toString() ?? "";
  }

  @override
  double? getEditorWidth(Map<String, dynamic>? pJson) {
    return null;
  }

  @override
  double? getEditorHeight(Map<String, dynamic>? pJson) {
    return null;
  }

  @override
  bool firesFocusCallback() {
    if (lastWidgetModel == null) {
      return false;
    }

    return lastWidgetModel!.isFocusable;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void _onPress() {
    if (model.styles.any((style) => style == ButtonCellEditorStyles.HYPERLINK)) {
      onEndEditing(_value);
    } else {
      if (_value == model.selectedValue) {
        if (model.styles.any((style) => style == ButtonCellEditorStyles.BUTTON)) {
          onEndEditing(model.selectedValue);
        } else {
          onEndEditing(model.deselectedValue);
        }
      } else {
        onEndEditing(model.selectedValue);
      }
    }
  }
}
