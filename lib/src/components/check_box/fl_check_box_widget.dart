import 'package:flutter/material.dart';

import '../../../util/jvx_colors.dart';
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
        color: JVxColors.COMPONENT_DISABLED,
        width: 2,
      );
    }

    return Checkbox(
      side: borderside,
      visualDensity: VisualDensity.compact,
      value: model.selected,
      onChanged: model.isEnabled ? (_) => onPress?.call() : null,
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlCheckBoxWidget({super.key, required super.model, required super.onPress, super.inTable = false});
}
