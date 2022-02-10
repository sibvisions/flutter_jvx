import 'dart:ui';

import '../../../components/dummy/fl_dummy_widget.dart';

import '../fl_component_model.dart';

/// The model for [FlDummyWidget]
class FlDummyModel extends FlComponentModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes the [FlDummyModel]
  FlDummyModel() : super() {
    minimumSize = const Size(55, 55);
  }
}
