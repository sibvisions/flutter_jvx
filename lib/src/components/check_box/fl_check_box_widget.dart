import 'package:flutter/material.dart';
import 'package:flutter_client/src/components/button/radio/fl_radio_button_widget.dart';

import '../../model/component/check_box/fl_check_box_model.dart';

class FlCheckBoxWidget extends FlRadioButtonWidget<FlCheckBoxModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden widget defaults
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget get image {
    return Checkbox(
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

  const FlCheckBoxWidget({Key? key, required FlCheckBoxModel model, required Function() onPress})
      : super(key: key, model: model, onPress: onPress);
}
