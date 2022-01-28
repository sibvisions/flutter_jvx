import 'package:flutter/material.dart';
import 'package:flutter_client/src/components/base_wrapper/fl_stateless_widget.dart';
import 'package:flutter_client/src/components/label/fl_label_widget.dart';
import 'package:flutter_client/src/model/component/editor/fl_text_field_model.dart';
import 'package:flutter_client/src/model/layout/alignments.dart';

class FlTextFieldWidget<T extends FlTextFieldModel> extends FlStatelessWidget<T> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final Function(String) valueChanged;

  final Function(String) endEditing;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlTextFieldWidget({Key? key, required T model, required this.valueChanged, required this.endEditing})
      : super(key: key, model: model);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    FlLabelWidget labelWidget = FlLabelWidget(model: model);

    return DecoratedBox(
      decoration: BoxDecoration(
          color: model.background,
          border: Border.all(
              color: model.isEnabled ? Colors.black : Colors.grey,
              style: model.isBorderVisible ? BorderStyle.solid : BorderStyle.none)),
      child: TextField(
          textAlign: HorizontalAlignmentE.toTextAlign(model.horizontalAlignment),
          readOnly: !(model.isEditable && model.isEnabled),
          style: labelWidget.getTextStyle()),
    );
  }
}
