import 'package:flutter/material.dart';

import '../../../util/jvx_colors.dart';
import '../../model/component/check_box/fl_check_box_model.dart';
import '../button/radio/fl_radio_button_widget.dart';

class FlCheckBoxWidget extends FlRadioButtonWidget<FlCheckBoxModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  static const String SWITCH_STYLE = "switch";

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden widget defaults
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget get image {
    if (model.styles.contains(SWITCH_STYLE)) {
      return Switch.adaptive(
        focusNode: focusNode,
        value: model.selected,
        onChanged: model.isEnabled ? (_) => onPress?.call() : null,
      );
    }

    BorderSide? borderside;

    if (!model.isEnabled) {
      borderside = const BorderSide(
        color: JVxColors.COMPONENT_DISABLED,
        width: 2,
      );
    }

    return Checkbox(
      side: borderside,
      focusNode: focusNode,
      visualDensity: VisualDensity.compact,
      value: model.selected,
      onChanged: model.isEnabled ? (_) => onPress?.call() : null,
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlCheckBoxWidget({
    super.key,
    required super.model,
    required super.focusNode,
    super.inTable = false,
    super.onPress,
    super.onPressDown,
    super.onPressUp,
  });
}
