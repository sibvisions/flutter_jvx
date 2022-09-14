import 'package:flutter/material.dart';

import '../../../../util/constants/i_color.dart';
import '../../../model/component/button/fl_toggle_button_model.dart';
import '../fl_button_widget.dart';

/// The widget representing a button.
class FlToggleButtonWidget extends FlButtonWidget<FlToggleButtonModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes a [FlButtonWidget]
  const FlToggleButtonWidget({Key? key, required FlToggleButtonModel model, required Function()? onPress})
      : super(key: key, model: model, onPress: onPress);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  ButtonStyle getButtonStyle(context) {
    return ButtonStyle(
      elevation: MaterialStateProperty.all(model.borderPainted ? 2 : 0),
      backgroundColor: model.selected
          ? MaterialStateProperty.all(IColor.toggleColor(model.background ?? Theme.of(context).colorScheme.primary))
          : model.background != null
              ? MaterialStateProperty.all(model.background)
              : null,
      padding: MaterialStateProperty.all(model.paddings),
      overlayColor: MaterialStateProperty.all(Colors.transparent),
    );
  }
}
