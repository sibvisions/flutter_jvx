import 'package:flutter/material.dart';

import 'fl_button_model.dart';
import 'fl_toggle_button_model.dart';

/// The model for [FlPopupMenuButtonWidget]
class FlPopupMenuButtonModel extends FlToggleButtonModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes the [FlButtonModel]
  FlPopupMenuButtonModel() : super() {
    paddings = const EdgeInsets.all(2);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden widget defaults
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlPopupMenuButtonModel get defaultModel => FlPopupMenuButtonModel();
}
