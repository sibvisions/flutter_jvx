import 'dart:math';

import 'package:flutter/widgets.dart';

import '../../../../services.dart';
import '../../../../util/parse_util.dart';
import '../../../model/component/editor/cell_editor/fl_number_cell_editor_model.dart';
import '../../../model/component/editor/text_field/fl_text_field_model.dart';
import '../../../model/data/column_definition.dart';
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
    required super.pCellEditorJson,
    required super.onValueChange,
    required super.onEndEditing,
    required super.onFocusChanged,
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
  createWidget(Map<String, dynamic>? pJson, bool pInTable) {
    FlTextFieldModel widgetModel = createWidgetModel();

    ICellEditor.applyEditorJson(widgetModel, pJson);

    lastWidgetModel = widgetModel;

    return FlTextFieldWidget(
      model: widgetModel,
      valueChanged: onValueChange,
      //(value) => onValueChange(numberFormatter.convertToNumber(value)),
      endEditing: onEndEditing,
      //(value) => onEndEditing(numberFormatter.convertToNumber(value)),
      focusNode: focusNode,
      textController: textController,
      inputFormatters: [numberFormatter],
      keyboardType: numberFormatter.getKeyboardType(),
      inTable: pInTable,
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
  double getContentPadding(Map<String, dynamic>? pJson, bool pInTable) {
    if (!pInTable) {
      return createWidget(pJson, false).extraWidthPaddings();
    }

    return 0.0;
  }

  @override
  double getEditorSize(Map<String, dynamic>? pJson, bool pInTable) {
    FlTextFieldModel widgetModel = createWidgetModel();

    ICellEditor.applyEditorJson(widgetModel, pJson);

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
      locale: IConfigService().getDisplayLanguage(),
    );
  }
}
