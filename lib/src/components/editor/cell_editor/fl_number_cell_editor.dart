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

import '../../../model/component/editor/cell_editor/fl_number_cell_editor_model.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../model/data/column_definition.dart';
import '../../../service/config/config_controller.dart';
import '../../../util/parse_util.dart';
import '../number_field/numeric_text_formatter.dart';
import '../text_field/fl_text_field_widget.dart';
import 'i_cell_editor.dart';

class FlNumberCellEditor
    extends IFocusableCellEditor<FlTextFieldModel, FlTextFieldWidget, FlNumberCellEditorModel, dynamic> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  late NumericTextFormatter numberFormatter;

  final TextEditingController textController = TextEditingController();

  FlTextFieldModel? lastWidgetModel;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlNumberCellEditor({
    required super.columnDefinition,
    required super.cellEditorJson,
    required super.onValueChange,
    required super.onEndEditing,
    super.onFocusChanged,
    super.isInTable,
  }) : super(
          model: FlNumberCellEditorModel(),
        ) {
    _recreateNumericFormatter();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void setValue(dynamic pValue) {
    if (pValue == null) {
      textController.clear();
    } else {
      String value = numberFormatter.getFormattedString(pValue);

      textController.value = textController.value.copyWith(
        text: value,
        selection: TextSelection.collapsed(offset: value.characters.length),
        composing: null,
      );
    }
  }

  @override
  createWidget(Map<String, dynamic>? pJson) {
    FlTextFieldModel widgetModel = createWidgetModel();

    applyEditorJson(widgetModel, pJson);

    lastWidgetModel = widgetModel;

    return FlTextFieldWidget(
      model: widgetModel,
      valueChanged: onValueChange,
      endEditing: onEndEditing,
      focusNode: focusNode,
      textController: textController,
      inputFormatters: [numberFormatter],
      keyboardType: numberFormatter.getKeyboardType(),
      isMandatory: columnDefinition?.nullable == false,
    );
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  String getValue() {
    return textController.text;
  }

  @override
  createWidgetModel() {
    return FlTextFieldModel();
  }

  @override
  void setColumnDefinition(ColumnDefinition? pColumnDefinition) {
    super.setColumnDefinition(pColumnDefinition);

    _recreateNumericFormatter();
  }

  @override
  String formatValue(dynamic pValue) {
    return numberFormatter.getFormattedString(pValue);
  }

  @override
  double getEditorWidth(Map<String, dynamic>? pJson) {
    FlTextFieldModel widgetModel = createWidgetModel();

    applyEditorJson(widgetModel, pJson);

    return (ParseUtil.getTextWidth(text: "w", style: widgetModel.createTextStyle()) * widgetModel.columns);
  }

  void _recreateNumericFormatter() {
    List<String> formatParts = model.numberFormat.split(";").first.split(".");
    String format = formatParts.first;

    // https://github.com/dart-lang/intl/issues/511
    if (formatParts.length >= 2) {
      String fractionDigits = formatParts.last;
      fractionDigits = fractionDigits.substring(0, min(fractionDigits.length, 18));
      format += ".$fractionDigits";
    }

    numberFormatter = NumericTextFormatter(
      numberFormat: format,
      length: columnDefinition?.length,
      precision: columnDefinition?.precision,
      scale: columnDefinition?.scale,
      signed: columnDefinition?.signed,
      locale: model.locale ?? ConfigController().getLanguage(),
    );
  }

  @override
  bool firesFocusCallback() {
    if (lastWidgetModel == null) {
      return false;
    }

    return lastWidgetModel!.isFocusable;
  }

  @override
  void focusChanged(bool pHasFocus) {
    if (lastWidgetModel == null) {
      return;
    }
    var widgetModel = lastWidgetModel!;

    if (!widgetModel.isReadOnly) {
      if (!focusNode.hasFocus) {
        onEndEditing(textController.text);
      }
    }
  }
}
