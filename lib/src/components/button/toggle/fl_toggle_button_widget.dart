import 'package:flutter/material.dart';
import 'package:flutter_client/util/constants/i_color.dart';

import '../../../model/component/button/fl_toggle_button_model.dart';
import '../../../model/layout/alignments.dart';
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
  Widget build(BuildContext context) {
    super.build(context);

    return ElevatedButton(
      onPressed: model.isEnabled && model.isFocusable ? onPress : null,
      child: Container(
        child: getButtonChild(),
        decoration: BoxDecoration(
            // 0x00000000 -> completely invisible shadow.
            // The shadow mimics a fake press.
            boxShadow: [
              BoxShadow(
                  blurRadius: 10.0,
                  color: model.selected
                      ? IColor.darken(model.background ?? Theme.of(context).backgroundColor)
                      : const Color(0x00000000))
            ]),
        alignment: FLUTTER_ALIGNMENT[model.horizontalAlignment.index][model.verticalAlignment.index],
      ),
      style: getButtonStyle(),
    );
  }
}
