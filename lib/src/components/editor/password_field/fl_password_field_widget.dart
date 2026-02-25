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

import '../../../model/component/fl_component_model.dart';
import '../../../util/widgets/password_strength_indicator.dart';
import '../text_field/fl_text_field_widget.dart';

class FlPasswordWidget extends FlTextFieldWidget<FlPasswordFieldModel> {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The height of password strength.
  // ignore: non_constant_identifier_names
  static double PASSWORD_STRENGTH_HEIGHT = 32;

  final ValueNotifier<bool> _showPlainText = ValueNotifier(false);

  final bool showPlainText;

  final bool showPasswordStrength;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlPasswordWidget({
    super.key,
    required super.model,
    required super.valueChanged,
    required super.endEditing,
    required super.focusNode,
    required super.textController,
    super.inputFormatters,
    super.isMandatory,
    super.hideClearIcon,
    super.showCopy,
    this.showPlainText = false,
    this.showPasswordStrength = false
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden widget defaults
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    Widget w;
    if (model.showPlainText || showPlainText) {
      w = ValueListenableBuilder(
          valueListenable: _showPlainText,
          builder: (context, value, _) {
            return super.build(context);
          }
      );
    }
    else {
      w = super.build(context);
    }

    if (model.showPasswordStrength || showPasswordStrength) {
      //don't use a column because it will create overflow exceptions if size changes
      //with Flex and Flexible, we avoid this
      w = Flex(direction: Axis.vertical,
          children: [
            w,
            Flexible(child: Column(
              children: [
                SizedBox(height: 8),
                PasswordStrengthIndicator(password: textController.text)
              ]
            )
          )
        ]
      );
    }

    return w;
  }

  @override
  bool get obscureText => !_showPlainText.value;

  @override
  List<Widget> createSuffixIconItems([BuildContext? context, bool forceAll = false]) {
    List<Widget> icons = super.createSuffixIconItems(context, forceAll);

    if (model.showPlainText || showPlainText)
    {
      if (!((textController.text.isEmpty || !model.isEnabled) && !forceAll)) {
        Widget iconEye = InkWell(
          canRequestFocus: false,
          onTap: () {
            _showPlainText.value = !_showPlainText.value;
          },
          child: createEmbeddableIcon(context, obscureText ? Icons.visibility : Icons.visibility_off),
        );

        icons.insert(0, iconEye);
      }
    }

    return icons;
  }
}
