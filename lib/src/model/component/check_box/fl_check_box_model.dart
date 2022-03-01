import 'package:flutter_client/src/model/component/button/fl_toggle_button_model.dart';

/// The model of a checkbox
class FlCheckBoxModel extends FlToggleButtonModel {
  // Checkbox never draws a border.
  @override
  bool get borderPainted => false;
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlCheckBoxModel() : super();
}
