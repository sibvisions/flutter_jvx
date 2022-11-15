import 'package:flutter/widgets.dart';

import '../../model/component/fl_component_model.dart';

class FlStatefulWidget<T extends FlComponentModel> extends StatefulWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // The model containing every information to build the button.
  final T model;

  const FlStatefulWidget({super.key, required this.model});

  @override
  FlStatefulWidgetState createState() => FlStatefulWidgetState();
}

class FlStatefulWidgetState<T extends FlStatefulWidget> extends State<T> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
