import 'package:flutter/material.dart';
import 'package:flutter_client/src/model/component/fl_component_model.dart';

abstract class FlStatelessWidget<T extends FlComponentModel> extends StatelessWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // The model containing every information to build the button.
  final T model;

  const FlStatelessWidget({Key? key, required this.model}) : super(key: key);
}
