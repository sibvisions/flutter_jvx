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

import '../../model/component/fl_component_model.dart';
import '../../util/jvx_colors.dart';
import '../button/radio/fl_radio_button_widget.dart';

class FlCheckBoxWidget extends FlRadioButtonWidget<FlCheckBoxModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden widget defaults
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget get image {
    if (model.isSwitch) {

      Widget switchWidget = Switch.adaptive(
        focusNode: radioFocusNode,
        value: model.selected,
        splashRadius: 10,
        onChanged: onPress != null && model.isEnabled ? (_) => onPress?.call() : null,
      );

      if (JVxColors.componentHeight() < JVxColors.MOBILE_HEIGHT) {
        return Transform.scale(
          scale: 0.8,
          child: switchWidget);
      }

      return switchWidget;
    }

    BorderSide? borderSide;

    if (!model.isEnabled) {
      borderSide = const BorderSide(
        color: JVxColors.COMPONENT_DISABLED,
        width: 2,
      );
    }

    return wrapShrink(Checkbox(
      materialTapTargetSize: shrinkSize == true ? MaterialTapTargetSize.shrinkWrap : null,
      side: borderSide,
      focusNode: radioFocusNode,
      visualDensity: shrinkSize == true ?
        const VisualDensity(
          horizontal: VisualDensity.minimumDensity,
          vertical: VisualDensity.minimumDensity
        )
        :
        VisualDensity.compact,
      value: model.selected,
      onChanged: model.isEnabled ? (_) => onPress?.call() : null,
    ));
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlCheckBoxWidget({
    super.key,
    required super.model,
    required super.focusNode,
    required super.radioFocusNode,
    super.onPress,
    super.onPressDown,
    super.onPressUp,
    super.shrinkSize
  });
}
