import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_client/src/components/editor/cell_editor/number_field/numeric_text_formatter.dart';
import 'package:flutter_client/src/components/editor/text_field/fl_text_field_widget.dart';
import 'package:flutter_client/src/model/component/editor/fl_text_field_model.dart';

class FlNumberFieldWidget extends FlTextFieldWidget {
  final NumericTextFormatter numberFormatter;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlNumberFieldWidget(
      {Key? key,
      required FlTextFieldModel model,
      required Function(String) valueChanged,
      required Function(String) endEditing,
      required FocusNode focusNode,
      required TextEditingController textController,
      required this.numberFormatter})
      : super(
            key: key,
            model: model,
            valueChanged: valueChanged,
            endEditing: endEditing,
            focusNode: focusNode,
            textController: textController);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden widget defaults
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  TextInputType get keyboardType => const TextInputType.numberWithOptions(signed: true, decimal: true);

  @override
  List<TextInputFormatter>? get inputFormatters => [numberFormatter];
}
