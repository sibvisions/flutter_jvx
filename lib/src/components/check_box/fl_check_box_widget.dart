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

  @override
  bool get enableFeedback => false;

  @override
  InteractiveInkFeatureFactory? get splashFactory => NoSplash.splashFactory;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlCheckBoxWidget({Key? key, required FlCheckBoxModel model, required Function() onPress})
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
