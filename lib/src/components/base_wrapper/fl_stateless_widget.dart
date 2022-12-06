import 'package:flutter/widgets.dart';

import '../../model/component/fl_component_model.dart';

/// The base class for all FlutterJVx's components.
abstract class FlStatelessWidget<T extends FlComponentModel> extends StatelessWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // The model of the component as sent by the server.
  final T model;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlStatelessWidget({super.key, required this.model});
}
