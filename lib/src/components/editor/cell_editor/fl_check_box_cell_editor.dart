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

import '../../../model/component/editor/cell_editor/fl_check_box_cell_editor_model.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../service/api/shared/api_object_property.dart';
import '../../base_wrapper/base_comp_wrapper_widget.dart';
import '../../button/fl_button_widget.dart';
import '../../button/radio/fl_radio_button_widget.dart';
import '../../button/toggle/fl_toggle_button_widget.dart';
import '../../check_box/fl_check_box_widget.dart';
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

  /// Whether to use minimal size for widget and remove paddings and reduce tap target size
  bool? shrinkSize;

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
    this.shrinkSize
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
  Widget createWidget(Map<String, dynamic>? pJson, [WidgetWrapper? pWrapper]) {
    FlCheckBoxModel widgetModel = createWidgetModel();

    applyEditorJson(widgetModel, pJson);

    bool isButton = model.styles.contains(FlCheckBoxModel.STYLE_UI_BUTTON);
    bool isToggle = model.styles.contains(FlCheckBoxModel.STYLE_UI_TOGGLEBUTTON);
    bool isRadio = model.styles.contains(FlCheckBoxModel.STYLE_UI_RADIOBUTTON);
    bool isHyperLink = model.styles.contains(FlCheckBoxModel.STYLE_UI_HYPERLINK);

    if (isButton || isHyperLink  || isToggle) {
      if ((isButton || isHyperLink) && model.selectedValue == null && model.deselectedValue == null) {
        widgetModel.labelModel.text = _value != null ? _value.toString() : "";
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

    if (isButton || isHyperLink) {
      Widget w = FlButtonWidget(
        model: widgetModel,
        focusNode: _buttonFocusNode,
        onPress: isEditable ? _onPress : null,
        shrinkSize: shrinkSize,
        tapTargetSize: isInTable ? MaterialTapTargetSize.shrinkWrap : null,
      );

      //otherwise the button will be to high
      if (isInTable) {
        w = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [w]
        );
      }

      return w;
    } else if (isRadio) {
      return FlRadioButtonWidget(
        model: widgetModel,
        focusNode: _buttonFocusNode,
        radioFocusNode: focusNode,
        onPress: isEditable ? _onPress : null,
        shrinkSize: shrinkSize,
        wrapper: pWrapper,
      );
    } else if (isToggle) {
      Widget w = FlToggleButtonWidget(
        model: widgetModel,
        focusNode: _buttonFocusNode,
        onPress: isEditable ? _onPress : null,
        shrinkSize: shrinkSize,
      );

      //otherwise the button will be to high
      if (isInTable) {
        w = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [w]
        );
      }

      return w;
    }

    return FlCheckBoxWidget(
      radioFocusNode: focusNode,
      focusNode: _buttonFocusNode,
      model: widgetModel,
      onPress: isEditable ? _onPress : null,
      shrinkSize: shrinkSize,
      wrapper: pWrapper
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
    if (model.styles.contains(FlCheckBoxModel.STYLE_UI_HYPERLINK)) {
      onEndEditing(_value);
    } else {
      if (_value == model.selectedValue) {
        if (model.styles.contains(FlCheckBoxModel.STYLE_UI_BUTTON)) {
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
