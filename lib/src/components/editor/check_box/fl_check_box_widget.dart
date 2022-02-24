import 'package:flutter/material.dart';
import 'package:flutter_client/src/components/base_wrapper/fl_stateless_data_widget.dart';
import 'package:flutter_client/src/model/component/fl_component_model.dart';

class FlCheckBoxWidget extends FlStatelessDataWidget<FlComponentModel, bool> {
  FlCheckBoxWidget(
      {required model, required Function(dynamic p1) valueChanged, required Function(dynamic p1) endEditing})
      : super(model: model, valueChanged: valueChanged, endEditing: endEditing);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
