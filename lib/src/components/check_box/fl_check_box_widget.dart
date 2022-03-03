import 'package:flutter/material.dart';

import '../../model/component/check_box/fl_check_box_model.dart';
import '../button/fl_button_widget.dart';

class FlCheckBoxWidget extends FlButtonWidget<FlCheckBoxModel> {
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
          onPress();
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
