/* 
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'package:flutter/material.dart';

import '../../../model/component/button/fl_radio_button_model.dart';
import '../../../util/jvx_colors.dart';
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
