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

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../../flutter_jvx.dart';
import '../button/radio/fl_radio_button_wrapper.dart';

class FlCheckBoxWrapper extends FlRadioButtonWrapper<FlCheckBoxModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlCheckBoxWrapper({super.key, required super.model});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlCheckBoxWrapperState createState() => FlCheckBoxWrapperState();
}

class FlCheckBoxWrapperState<T extends FlCheckBoxModel> extends FlRadioButtonWrapperState<T> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    FlCheckBoxWidget checkboxWidget = FlCheckBoxWidget(
      focusNode: buttonFocusNode,
      radioFocusNode: focusNode,
      model: model,
      onPress: sendButtonPressed,
      wrapper: (widget, padding) => wrapWithBadge(context, widget ?? ImageLoader.DEFAULT_IMAGE, padding: padding)
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return wrapWidget(context, checkboxWidget, false);
  }
}
