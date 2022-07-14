import 'package:flutter/material.dart';

import '../../model/component/fl_component_model.dart';

class FlStatefulWidget<T extends FlComponentModel> extends StatefulWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // The model containing every information to build the button.
  final T model;

  const FlStatefulWidget({Key? key, required this.model}) : super(key: key);

  @override
  FlStatefulWidgetState createState() => FlStatefulWidgetState();
}

class FlStatefulWidgetState<T extends FlStatefulWidget> extends State<T> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
