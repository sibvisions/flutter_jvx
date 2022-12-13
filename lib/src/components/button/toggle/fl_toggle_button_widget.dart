/* Copyright 2022 SIB Visions GmbH
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

import '../../../model/component/button/fl_toggle_button_model.dart';
import '../../../util/jvx_colors.dart';
import '../fl_button_widget.dart';

/// The widget representing a button.
class FlToggleButtonWidget extends FlButtonWidget<FlToggleButtonModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes a [FlButtonWidget]
  const FlToggleButtonWidget({
    super.key,
    required super.model,
    super.onPress,
    super.onFocusGained,
    super.onFocusLost,
    super.onPressDown,
    super.onPressUp,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  ButtonStyle createButtonStyle(context) {
    ButtonStyle buttonStyle = super.createButtonStyle(context);

    Color? backgroundColor;
    if (!model.isEnabled) {
      backgroundColor = JVxColors.COMPONENT_DISABLED;
    } else {
      backgroundColor = model.background;
    }

    if (model.isEnabled && model.selected) {
      buttonStyle = buttonStyle.copyWith(
        backgroundColor: MaterialStateProperty.all(
          JVxColors.toggleColor(backgroundColor ?? Theme.of(context).colorScheme.primary),
        ),
      );
    }

    return buttonStyle;
  }
}
