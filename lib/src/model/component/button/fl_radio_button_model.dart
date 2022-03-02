import 'package:flutter/material.dart';

import 'fl_button_model.dart';
import 'fl_toggle_button_model.dart';

/// The model for [FlRadioButtonWidget]
class FlRadioButtonModel extends FlToggleButtonModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes the [FlButtonModel]
  FlRadioButtonModel() : super() {
    paddings = const EdgeInsets.all(2);
  }
}
