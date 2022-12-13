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

import '../../model/component/check_box/fl_check_box_model.dart';
import '../../util/jvx_colors.dart';
import '../button/radio/fl_radio_button_widget.dart';

class FlCheckBoxWidget extends FlRadioButtonWidget<FlCheckBoxModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  static const String SWITCH_STYLE = "f_switch";

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
