import 'package:flutter/material.dart';
import 'package:flutter_client/src/components/editor/number_field/numeric_text_formatter.dart';
import 'package:flutter_client/src/model/component/editor/cell_editor/fl_number_cell_editor_model.dart';
import 'package:flutter_client/src/model/data/column_definition.dart';

import '../../../model/component/editor/text_field/fl_text_field_model.dart';
import '../text_field/fl_text_field_widget.dart';
import 'i_cell_editor.dart';

class FlNumberCellEditor extends ICellEditor<FlNumberCellEditorModel, String> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ColumnDefinition? _columnDefinition;

  dynamic _value;

  late NumericTextFormatter numberFormatter;

  final TextEditingController textController = TextEditingController();

  final FocusNode focusNode = FocusNode();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlNumberCellEditor({
    required String id,
    required Map<String, dynamic> pCellEditorJson,
    required Function(String) onChange,
    required Function(String) onEndEditing,
  }) : super(
          id: id,
          model: FlNumberCellEditorModel(),
          pCellEditorJson: pCellEditorJson,
          onValueChange: onChange,
          onEndEditing: onEndEditing,
        ) {
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        onEndEditing(textController.text);
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
  FlTextFieldWidget getWidget(BuildContext pContext) {
    return FlTextFieldWidget(
      model: FlTextFieldModel(),
      valueChanged: onValueChange, //(value) => onValueChange(numberFormatter.convertToNumber(value)),
      endEditing: onEndEditing, //(value) => onEndEditing(numberFormatter.convertToNumber(value)),
      focusNode: focusNode,
      textController: textController,
      keyboardType: numberFormatter.getKeyboardType(),
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
  bool isActionCellEditor() {
    return false;
  }

  @override
  ColumnDefinition? getColumnDefinition() {
    return _columnDefinition;
  }

  @override
  FlTextFieldModel getWidgetModel() {
    return FlTextFieldModel();
  }

  @override
  void setColumnDefinition(ColumnDefinition? pColumnDefinition) {
    _columnDefinition = pColumnDefinition;

    _recreateNumericFormatter();
  }

  void _recreateNumericFormatter() {
    // TODO locale
    numberFormatter = NumericTextFormatter(
      numberFormat: model.numberFormat,
      length: _columnDefinition?.length,
      precision: _columnDefinition?.precision,
      scale: _columnDefinition?.scale,
      signed: _columnDefinition?.signed,
    );
  }
}
