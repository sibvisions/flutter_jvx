import 'package:flutter/material.dart';

import '../../../../util/jvx_colors.dart';
import '../../../model/component/button/fl_toggle_button_model.dart';
import '../fl_button_widget.dart';

/// The widget representing a button.
class FlToggleButtonWidget extends FlButtonWidget<FlToggleButtonModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes a [FlButtonWidget]
  const FlToggleButtonWidget({
    super.key,
    required super.model,
    required super.onPress,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  ButtonStyle createButtonStyle(context) {
    ButtonStyle buttonStyle = super.createButtonStyle(context);

    Color? backgroundColor;
    if (!model.isEnabled) {
      backgroundColor = JVxColors.COMPONENT_DISABLED;
    } else {
      backgroundColor = model.background;
    }

    if (model.isEnabled && model.selected) {
      buttonStyle = buttonStyle.copyWith(
        backgroundColor: MaterialStateProperty.all(
          JVxColors.toggleColor(backgroundColor ?? Theme.of(context).colorScheme.primary),
        ),
      );
    }

    return buttonStyle;
  }
}
