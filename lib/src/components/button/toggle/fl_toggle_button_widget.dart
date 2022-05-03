import 'package:flutter/material.dart';
import 'package:flutter_client/util/constants/i_color.dart';

import '../../../model/component/button/fl_toggle_button_model.dart';
import '../fl_button_widget.dart';

/// The widget representing a button.
class FlToggleButtonWidget extends FlButtonWidget<FlToggleButtonModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes a [FlButtonWidget]
  const FlToggleButtonWidget({Key? key, required FlToggleButtonModel model, required VoidCallback onPress})
      : super(key: key, model: model, onPress: onPress);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  ButtonStyle getButtonStyle() {
    return ButtonStyle(
      elevation: MaterialStateProperty.all(model.borderPainted ? 2 : 0),
      backgroundColor: model.background != null ? MaterialStateProperty.all(model.background) : null,
      padding: MaterialStateProperty.all(model.paddings),
    );
  }

  @override
  BoxDecoration? getBoxDecoration(BuildContext pContext) {
    return BoxDecoration(
      // 0x00000000 -> completely invisible shadow.
      // The shadow mimics a fake press.
      boxShadow: [
        BoxShadow(
          blurRadius: 10.0,
          color: model.selected
              ? IColor.darken(model.background ?? Theme.of(pContext).primaryColor)
              : const Color(0x00000000),
        )
      ],
    );
  }
}
