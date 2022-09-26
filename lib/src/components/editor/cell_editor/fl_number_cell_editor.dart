import 'package:flutter/widgets.dart';

import '../../../../services.dart';
import '../../../model/component/editor/cell_editor/fl_number_cell_editor_model.dart';
import '../../../model/component/editor/text_field/fl_text_field_model.dart';
import '../../../model/data/column_definition.dart';
import '../number_field/numeric_text_formatter.dart';
import '../text_field/fl_text_field_widget.dart';
import 'i_cell_editor.dart';

class FlNumberCellEditor extends ICellEditor<FlTextFieldModel, FlTextFieldWidget, FlNumberCellEditorModel, String> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
  createWidget(Map<String, dynamic>? pJson, bool pInTable) {
    FlTextFieldModel widgetModel = createWidgetModel();

    ICellEditor.applyEditorJson(widgetModel, pJson);

    return FlTextFieldWidget(
      model: widgetModel,
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
  createWidgetModel() {
    return FlTextFieldModel();
  }

  @override
  void setColumnDefinition(ColumnDefinition? pColumnDefinition) {
    super.setColumnDefinition(pColumnDefinition);

    _recreateNumericFormatter();
  }

  @override
  String formatValue(Object pValue) {
    return numberFormatter.getFormattedString(pValue);
  }

  @override
  double get additionalTablePadding => 0.0;

  void _recreateNumericFormatter() {
    numberFormatter = NumericTextFormatter(
      numberFormat: model.numberFormat,
      length: columnDefinition?.length,
      precision: columnDefinition?.precision,
      scale: columnDefinition?.scale,
      signed: columnDefinition?.signed,
      locale: IConfigService().getLanguage(),
    );
  }
}
