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
  ButtonStyle createButtonStyle(context) {
    ButtonStyle buttonStyle = super.createButtonStyle(context);

    Color? backgroundColor;
    if (!model.isEnabled) {
      backgroundColor = IColorConstants.COMPONENT_DISABLED;
    } else {
      backgroundColor = model.background;
    }

    if (model.isEnabled && model.selected) {
      buttonStyle = buttonStyle.copyWith(
        backgroundColor: MaterialStateProperty.all(
          IColor.toggleColor(backgroundColor ?? Theme.of(context).colorScheme.primary),
        ),
      );
    }

    return buttonStyle;
  }
}
