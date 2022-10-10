import 'package:flutter/material.dart';

import '../../../../util/constants/i_color.dart';
import '../../../model/component/button/fl_radio_button_model.dart';
import '../fl_button_widget.dart';

class FlRadioButtonWidget<T extends FlRadioButtonModel> extends FlButtonWidget<T> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden widget defaults
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget get image {
    return Builder(builder: (context) {
      return Theme(
        data: Theme.of(context).copyWith(
          disabledColor: IColorConstants.COMPONENT_DISABLED,
        ),
        child: Radio<bool>(
          visualDensity: VisualDensity.compact,
          value: true,
          groupValue: model.selected,
          onChanged: model.isEnabled ? (_) => onPress?.call() : null,
          toggleable: true,
        ),
      );
    });
  }

  InteractiveInkFeatureFactory? get splashFactory => NoSplash.splashFactory;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlRadioButtonWidget({Key? key, required super.model, required Function()? onPress})
      : super(key: key, onPress: onPress);

  @override
  Function()? getOnPressed() {
    return model.isEnabled && model.isFocusable ? () {} : null;
  }

  @override
  ButtonStyle createButtonStyle(context) {
    return ButtonStyle(
      elevation: MaterialStateProperty.all(model.borderPainted ? 2 : 0),
      backgroundColor: MaterialStateProperty.all(model.background ?? Colors.transparent),
      foregroundColor:
          model.background == null ? MaterialStateProperty.all(Theme.of(context).colorScheme.onBackground) : null,
      padding: MaterialStateProperty.all(model.paddings),
      splashFactory: splashFactory,
      overlayColor: MaterialStateProperty.all(Colors.transparent),
    );
  }

  @override
  Widget? createButtonChild() {
    Widget? child = super.createButtonChild();

    if (child != null) {
      child = InkWell(
        onTap: super.getOnPressed(),
        child: Ink(
          padding: const EdgeInsets.only(right: 10),
          child: child,
        ),
      );
    }
    return child;
  }
}
