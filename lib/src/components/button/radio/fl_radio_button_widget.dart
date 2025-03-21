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

import '../../../model/component/editor/cell_editor/fl_choice_cell_editor_model.dart';
import '../../../model/component/fl_component_model.dart';
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
        child: wrapShrink(Radio<bool>(
          materialTapTargetSize: shrinkSize == true ? MaterialTapTargetSize.shrinkWrap : null,
          visualDensity: shrinkSize == true ?
          const VisualDensity(
            horizontal: VisualDensity.minimumDensity,
            vertical: VisualDensity.minimumDensity
          )
          :
          VisualDensity.compact,
          value: true,
          focusNode: radioFocusNode,
          groupValue: model.selected,
          onChanged: model.isEnabled ? (_) => onPress?.call() : null,
          toggleable: true,
        )),
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

  final FocusNode radioFocusNode;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  ButtonStyle createButtonStyle(context) {
    radioFocusNode.canRequestFocus = model.isFocusable;

    return ButtonStyle(
      minimumSize: WidgetStateProperty.all(Size.zero),
      elevation: WidgetStateProperty.all(model.borderPainted ? 2 : 0),
      backgroundColor: WidgetStateProperty.all(model.background ?? Colors.transparent),
      foregroundColor: WidgetStateProperty.all(Theme.of(context).textTheme.bodyLarge?.color),
      //always EdgeInsets.zero paddings just looks wrong with border painted
      padding: WidgetStateProperty.all(shrinkSize == true ?
        (model.borderPainted ? const EdgeInsets.all(2) : EdgeInsets.zero)
        :
        model.paddings
      ),
      tapTargetSize: shrinkSize == true ? MaterialTapTargetSize.shrinkWrap : tapTargetSize,
      splashFactory: splashFactory,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
    );
  }

  const FlRadioButtonWidget({
    super.key,
    required super.model,
    required super.focusNode,
    required this.radioFocusNode,
    super.shrinkSize,
    super.onPress,
    super.onPressDown,
    super.onPressUp,
  });

  @override
  Widget? createButtonChild(BuildContext context) {
    Widget? child = super.createButtonChild(context);

    if (child != null) {
      child = InkWell(
        canRequestFocus: false,
        onTap: super.getOnPressed(context),
        child: Ink(
          padding: model.labelModel.text.isEmpty ? EdgeInsets.zero : const EdgeInsets.only(right: 10),
          child: child,
        ),
      );
    }
    return child;
  }

  @override
  Function()? getOnPressed(BuildContext context) {
    return model.isEnabled && model.isFocusable ? FlButtonWidget.EMPTY_CALLBACK : null;
  }

  Widget wrapShrink(Widget widget) {
    if (shrinkSize != true) {
      return widget;
    }

    return SizedBox(
      width: FlChoiceCellEditorModel.IMAGE_SIZE_MIN,
      height: FlChoiceCellEditorModel.IMAGE_SIZE_MIN,
      child: widget
    );
  }
}
