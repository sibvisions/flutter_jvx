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

import '../text_field/fl_text_field_widget.dart';

class FlPasswordWidget extends FlTextFieldWidget {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final ValueNotifier<bool> _showPlainText = ValueNotifier(false);

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
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden widget defaults
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    if (model.showClearText) {
      return ValueListenableBuilder(
          valueListenable: _showPlainText,
          builder: (context, value, _) {
            return super.build(context);
          }
      );
    }
    else {
      return super.build(context);
    }
  }

  @override
  bool get obscureText => !_showPlainText.value;

  @override
  List<Widget> createSuffixIconItems([BuildContext? context, bool forceAll = false]) {
    List<Widget> icons = super.createSuffixIconItems(context, forceAll);

    if (model.showClearText)
    {
      if (!((textController.text.isEmpty || model.isReadOnly) && !forceAll)) {
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
