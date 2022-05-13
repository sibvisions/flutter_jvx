import 'package:flutter/material.dart';

import '../../../../main.dart';
import '../../../../util/constants/i_color.dart';
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
    return ElevatedButton(
      onPressed: getOnPressed(),
      child: Container(
        child: getButtonChild(),
        decoration: getBoxDecoration(context),
        alignment: FLUTTER_ALIGNMENT[model.horizontalAlignment.index][model.verticalAlignment.index],
      ),
      style: getButtonStyle(),
    );
  }

  @override
  ButtonStyle getButtonStyle() {
    return ButtonStyle(
      elevation: MaterialStateProperty.all(model.borderPainted ? 2 : 0),
      backgroundColor: model.selected
          ? MaterialStateProperty.all(IColor.toggleColor(model.background ?? themeData.primaryColor))
          : model.background != null
              ? MaterialStateProperty.all(model.background)
              : null,
      padding: MaterialStateProperty.all(model.paddings),
    );
  }
}
