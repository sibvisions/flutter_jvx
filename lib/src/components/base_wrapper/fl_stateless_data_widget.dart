import 'package:flutter/material.dart';

import '../../model/component/fl_component_model.dart';
import 'fl_stateless_widget.dart';

abstract class FlStatelessDataWidget<T extends FlComponentModel, C> extends FlStatelessWidget<T> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The callback notifying that the editor value has changed.
  final Function(C) valueChanged;

  /// The callback notifying that the editor value has changed and the editing was completed.
  final Function(C) endEditing;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlStatelessDataWidget({Key? key, required T model, required this.valueChanged, required this.endEditing})
      : super(key: key, model: model);
}
