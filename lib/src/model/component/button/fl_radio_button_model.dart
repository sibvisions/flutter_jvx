import 'package:flutter/widgets.dart';

import '../../layout/alignments.dart';
import 'fl_button_model.dart';
import 'fl_toggle_button_model.dart';

/// The model for [FlRadioButtonWidget]
class FlRadioButtonModel extends FlToggleButtonModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes the [FlButtonModel]
  FlRadioButtonModel() : super() {
    horizontalAlignment = HorizontalAlignment.LEFT;
    paddings = const EdgeInsets.all(2);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden widget defaults
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // Radiobutton never draws a border.
  @override
  bool get borderPainted => false;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlRadioButtonModel get defaultModel => FlRadioButtonModel();
}
