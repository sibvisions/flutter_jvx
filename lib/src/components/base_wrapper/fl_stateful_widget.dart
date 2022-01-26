import 'package:flutter/material.dart';
import 'package:flutter_client/src/model/component/fl_component_model.dart';

class FlStatefulWidget<T extends FlComponentModel> extends StatefulWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // The model containing every information to build the button.
  final T model;

  const FlStatefulWidget({Key? key, required this.model}) : super(key: key);

  @override
  _FlStatefulWidgetState createState() => _FlStatefulWidgetState();
}

class _FlStatefulWidgetState extends State<FlStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
