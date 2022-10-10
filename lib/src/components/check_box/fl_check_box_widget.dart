import 'package:flutter/material.dart';

import '../../../util/constants/i_color.dart';
import '../../model/component/check_box/fl_check_box_model.dart';
import '../button/radio/fl_radio_button_widget.dart';

class FlCheckBoxWidget extends FlRadioButtonWidget<FlCheckBoxModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden widget defaults
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget get image {
    BorderSide? borderside;

    if (!model.isEnabled) {
      borderside = const BorderSide(
        color: IColorConstants.COMPONENT_DISABLED,
        width: 2,
      );
    }

    return Checkbox(
      side: borderside,
      visualDensity: VisualDensity.compact,
      value: model.selected,
      onChanged: (_) {
        if (model.isEnabled) {
          onPress?.call();
        }
      },
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlCheckBoxWidget({Key? key, required FlCheckBoxModel model, required Function()? onPress})
      : super(key: key, model: model, onPress: onPress);
}
