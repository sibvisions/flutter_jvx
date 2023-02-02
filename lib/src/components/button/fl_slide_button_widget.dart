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

import 'dart:math';

import 'package:action_slider/action_slider.dart';
import 'package:flutter/material.dart';

import '../../model/component/fl_component_model.dart';
import '../../util/image/image_loader.dart';
import '../../util/jvx_colors.dart';
import '../base_wrapper/fl_stateless_widget.dart';
import '../label/fl_label_widget.dart';

/// The widget representing a button.
class FlSlideButtonWidget<T extends FlButtonModel> extends FlStatelessWidget<T> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The function to call when the button slides.
  final Function(ActionSliderController)? onSlide;

  /// The function to call when the button is pressed.
  final Function(ActionSliderController)? onPress;

  /// The function if the button gained focus.
  final VoidCallback? onFocusGained;

  /// The function if the button lost focus.
  final VoidCallback? onFocusLost;

  /// The function if the mouse was pressed down.
  final Function(DragDownDetails)? onPressDown;

  /// The function if the mouse click is released.
  final Function(DragEndDetails)? onPressUp;

  /// The focus node of the button.
  final FocusNode focusNode;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overrideable widget defaults
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Widget? get image {
    if (model.image != null) {
      return ImageLoader.loadImage(
        model.image!,
        pWantedColor: model.createTextStyle().color,
      );
    }
    return null;
  }

  bool get isButtonFocusable => model.isFocusable;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes a [FlSlideButtonWidget]
  const FlSlideButtonWidget({
    super.key,
    required super.model,
    required this.focusNode,
    this.onSlide,
    this.onPress,
    this.onFocusGained,
    this.onFocusLost,
    this.onPressDown,
    this.onPressUp,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        Size minimumSize = model.minimumSize!;
        return OverflowBox(
          minWidth: minimumSize.width,
          maxWidth: max(minimumSize.width, constraints.maxWidth),
          minHeight: minimumSize.height,
          maxHeight: max(minimumSize.height, constraints.maxHeight),
          child: ActionSlider.standard(
            action: onSlide,
            onTap: onPress,
            width: max(minimumSize.width, constraints.maxWidth),
            height: max(minimumSize.height, constraints.maxHeight),
            backgroundColor: model.background,
            icon: image,
            rolling: true,
            child: createTextWidget(),
          ),
        );
      },
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Gets the text widget of the button with the label model.
  Widget createTextWidget() {
    TextStyle textStyle = model.labelModel.createTextStyle();

    if (!model.isEnabled) {
      textStyle = textStyle.copyWith(color: JVxColors.darken(JVxColors.COMPONENT_DISABLED));
    } else if (model.labelModel.foreground == null && model.style == "hyperlink") {
      textStyle = textStyle.copyWith(color: Colors.blue);
    }

    return FlLabelWidget.getTextWidget(
      model.labelModel,
      pTextStyle: textStyle,
    );
  }
}
