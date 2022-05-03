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

  @override
  bool get enableFeedback => false;

  @override
  InteractiveInkFeatureFactory? get splashFactory => NoSplash.splashFactory;
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlRadioButtonWidget({Key? key, required FlRadioButtonModel model, required Function() onPress})
      : super(key: key, model: model, onPress: onPress);

  @override
  Function()? getOnPressed() {
    return model.isEnabled && model.isFocusable ? () {} : null;
  }

  @override
  Widget? getButtonChild() {
    Widget? child = super.getButtonChild();

    if (child != null) {
      child = GestureDetector(
        child: Container(
          padding: const EdgeInsets.only(right: 10),
          child: child,
        ),
        onTap: super.getOnPressed(),
      );
    }
    return child;
  }
}
