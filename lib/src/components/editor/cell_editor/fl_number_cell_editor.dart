import 'package:flutter/widgets.dart';

import '../../../../mixin/config_service_mixin.dart';
import '../../../model/component/editor/cell_editor/fl_number_cell_editor_model.dart';
import '../../../model/component/editor/text_field/fl_text_field_model.dart';
import '../../../model/data/column_definition.dart';
import '../number_field/numeric_text_formatter.dart';
import '../text_field/fl_text_field_widget.dart';
import 'i_cell_editor.dart';

class FlNumberCellEditor extends ICellEditor<FlNumberCellEditorModel, String> with ConfigServiceGetterMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ColumnDefinition? _columnDefinition;

  late NumericTextFormatter numberFormatter;

  final TextEditingController textController = TextEditingController();

  final FocusNode focusNode = FocusNode();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlNumberCellEditor({
    ColumnDefinition? columnDefinition,
    required Map<String, dynamic> pCellEditorJson,
    required Function(String) onChange,
    required Function(String) onEndEditing,
  }) : super(
          columnDefinition: columnDefinition,
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
  FlTextFieldWidget createWidget() {
    return FlTextFieldWidget(
      model: FlTextFieldModel(),
      valueChanged: onValueChange,
      //(value) => onValueChange(numberFormatter.convertToNumber(value)),
      endEditing: onEndEditing,
      //(value) => onEndEditing(numberFormatter.convertToNumber(value)),
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
  FlTextFieldModel createWidgetModel() {
    return FlTextFieldModel();
  }

  @override
  void setColumnDefinition(ColumnDefinition? pColumnDefinition) {
    _columnDefinition = pColumnDefinition;

    _recreateNumericFormatter();
  }

  void _recreateNumericFormatter() {
    numberFormatter = NumericTextFormatter(
      numberFormat: model.numberFormat,
      length: _columnDefinition?.length,
      precision: _columnDefinition?.precision,
      scale: _columnDefinition?.scale,
      signed: _columnDefinition?.signed,
      locale: getConfigService().getLanguage(),
    );
  }

  @override
  String formatValue(Object pValue) {
    return numberFormatter.getFormattedString(pValue);
  }

  @override
  FlTextFieldWidget? createTableWidget() {
    return null;
  }

  @override
  double get additionalTablePadding => 0.0;
}
