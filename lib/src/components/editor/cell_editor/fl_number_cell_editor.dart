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
import '../../../model/component/editor/text_field/fl_text_field_model.dart';
import '../../../model/data/column_definition.dart';
import '../../../service/config/config_service.dart';
import '../../../util/parse_util.dart';
import '../number_field/numeric_text_formatter.dart';
import '../text_field/fl_text_field_widget.dart';
import 'i_cell_editor.dart';

class FlNumberCellEditor extends ICellEditor<FlTextFieldModel, FlTextFieldWidget, FlNumberCellEditorModel, dynamic> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  late NumericTextFormatter numberFormatter;

  final TextEditingController textController = TextEditingController();

  final FocusNode focusNode = FocusNode();

  FlTextFieldModel? lastWidgetModel;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlNumberCellEditor({
    required super.columnDefinition,
    required super.cellEditorJson,
    required super.onValueChange,
    required super.onEndEditing,
    required super.onFocusChanged,
    super.isInTable,
  }) : super(
          model: FlNumberCellEditorModel(),
        ) {
    focusNode.addListener(() {
      if (lastWidgetModel == null) {
        return;
      }

      var widgetModel = lastWidgetModel!;

      if (!widgetModel.isReadOnly) {
        if (!focusNode.hasFocus) {
          onEndEditing(numberFormatter.numberFormatter.parse(textController.text));
        }
      }

      if (widgetModel.isFocusable) {
        onFocusChanged(focusNode.hasFocus);
      }
    });

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
      // (value) => onValueChange(numberFormatter.convertToNumber(value)),
      endEditing: onEndEditing,
      // (value) => onEndEditing(numberFormatter.convertToNumber(value)),
      focusNode: focusNode,
      textController: textController,
      inputFormatters: [numberFormatter],
      keyboardType: numberFormatter.getKeyboardType(),
      // inTable: isInTable,
      isMandatory: columnDefinition?.nullable == false,
    );
  }

  @override
  void dispose() {
    focusNode.dispose();
    textController.dispose();
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
  double getContentPadding(Map<String, dynamic>? pJson) {
    if (!isInTable) {
      return createWidget(pJson).extraWidthPaddings();
    }

    return 0.0;
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
      locale: model.locale ?? ConfigService().getLanguage(),
    );
  }
}
