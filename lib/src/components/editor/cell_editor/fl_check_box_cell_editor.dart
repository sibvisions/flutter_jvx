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

import '../../../model/component/editor/cell_editor/fl_check_box_cell_editor_model.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../service/api/shared/api_object_property.dart';
import '../../check_box/fl_check_box_widget.dart';
import 'i_cell_editor.dart';

class FlCheckBoxCellEditor extends ICellEditor<FlCheckBoxModel, FlCheckBoxWidget, FlCheckBoxCellEditorModel, dynamic> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FocusNode buttonFocusNode = FocusNode();

  FocusNode focusNode = FocusNode();

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
    required super.onFocusChanged,
    super.isInTable,
  }) : super(
          model: FlCheckBoxCellEditorModel(),
        ) {
    focusNode.addListener(() {
      if (lastWidgetModel == null) {
        return;
      }

      var widgetModel = lastWidgetModel!;

      if (widgetModel.isFocusable) {
        onFocusChanged(focusNode.hasFocus);
      }
    });
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void setValue(dynamic pValue) {
    _value = pValue;
  }

  @override
  createWidget(Map<String, dynamic>? pJson) {
    FlCheckBoxModel widgetModel = createWidgetModel();

    applyEditorJson(widgetModel, pJson);

    lastWidgetModel = widgetModel;

    bool isEditable = true;
    if (pJson?.containsKey(ApiObjectProperty.cellEditorEditable) == true) {
      isEditable = pJson![ApiObjectProperty.cellEditorEditable];
    }

    return FlCheckBoxWidget(
      radioFocusNode: focusNode,
      focusNode: buttonFocusNode,
      model: widgetModel,
      onPress: isEditable ? _onPress : null,
      inTable: isInTable,
    );
  }

  @override
  createWidgetModel() {
    FlCheckBoxModel widgetModel = FlCheckBoxModel();

    widgetModel.labelModel.text = model.text;
    widgetModel.selected = model.selectedValue == _value;

    return widgetModel;
  }

  @override
  dynamic getValue() {
    return _value;
  }

  @override
  void dispose() {
    buttonFocusNode.dispose();
    focusNode.dispose();
  }

  @override
  String formatValue(dynamic pValue) {
    return pValue?.toString() ?? "";
  }

  @override
  double? getEditorWidth(Map<String, dynamic>? pJson) {
    return null;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void _onPress() {
    if (_value == model.selectedValue) {
      onEndEditing(model.deselectedValue);
    } else {
      onEndEditing(model.selectedValue);
    }
  }
}
