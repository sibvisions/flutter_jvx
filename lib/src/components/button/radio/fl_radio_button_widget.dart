import 'package:flutter/material.dart';

import '../../../model/component/button/fl_radio_button_model.dart';
import '../fl_button_widget.dart';

class FlRadioButtonWidget extends FlButtonWidget<FlRadioButtonModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden widget defaults
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget get image {
    return Radio<bool>(
      visualDensity: VisualDensity.compact,
      value: true,
      groupValue: model.selected,
      onChanged: (_) {
        if (model.isEnabled) {
          onPress();
        }
      },
      toggleable: true,
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlRadioButtonWidget({Key? key, required FlRadioButtonModel model, required Function() onPress})
      : super(key: key, model: model, onPress: onPress);
}
