import 'package:flutter/cupertino.dart';
import '../button/fl_toggle_button_model.dart';

/// The model of a checkbox
class FlCheckBoxModel extends FlToggleButtonModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlCheckBoxModel() : super() {
    paddings = const EdgeInsets.all(2);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden widget defaults
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // Checkbox never draws a border.
  @override
  bool get borderPainted => false;
}
