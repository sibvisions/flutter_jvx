import 'package:flutter/cupertino.dart';

import '../../layout/alignments.dart';
import '../button/fl_radio_button_model.dart';

/// The model of a checkbox
class FlCheckBoxModel extends FlRadioButtonModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlCheckBoxModel() : super() {
    paddings = const EdgeInsets.all(2);
    horizontalAlignment = HorizontalAlignment.LEFT;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden widget defaults
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // Checkbox never draws a border.
  @override
  bool get borderPainted => false;
}
