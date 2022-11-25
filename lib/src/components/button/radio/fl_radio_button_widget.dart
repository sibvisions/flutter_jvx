import 'package:flutter/material.dart';

import '../../../../util/jvx_colors.dart';
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
          disabledColor: JVxColors.COMPONENT_DISABLED,
        ),
        child: Radio<bool>(
          visualDensity: VisualDensity.compact,
          value: true,
          focusNode: focusNode,
          groupValue: model.selected,
          onChanged: model.isEnabled ? (_) => onPress?.call() : null,
          toggleable: true,
        ),
      );
    });
  }

  @override
  bool get isButtonFocusable => false;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overrideable widget defaults
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  InteractiveInkFeatureFactory? get splashFactory => NoSplash.splashFactory;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final bool inTable;

  final FocusNode focusNode;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlRadioButtonWidget({
    super.key,
    required super.model,
    required this.focusNode,
    super.onPress,
    super.onPressDown,
    super.onPressUp,
    this.inTable = false,
  });

  @override
  ButtonStyle createButtonStyle(context) {
    focusNode.canRequestFocus = model.isFocusable;

    return ButtonStyle(
      elevation: MaterialStateProperty.all(model.borderPainted ? 2 : 0),
      backgroundColor: MaterialStateProperty.all(model.background ?? Colors.transparent),
      foregroundColor: MaterialStateProperty.all(Theme.of(context).textTheme.bodyText1?.color),
      padding: MaterialStateProperty.all(model.paddings),
      splashFactory: splashFactory,
      overlayColor: MaterialStateProperty.all(Colors.transparent),
    );
  }

  @override
  Widget? createButtonChild(BuildContext context) {
    Widget? child = super.createButtonChild(context);

    if (child != null) {
      child = InkWell(
        canRequestFocus: false,
        onTap: super.getOnPressed(context),
        child: Ink(
          padding: inTable ? EdgeInsets.zero : const EdgeInsets.only(right: 10),
          child: child,
        ),
      );
    }
    return child;
  }

  @override
  Function()? getOnPressed(BuildContext context) {
    return model.isEnabled && model.isFocusable ? () {} : null;
  }
}
