/*
 * Copyright 2023 SIB Visions GmbH
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
import 'package:html_editor_enhanced/html_editor.dart';

import '../../../components.dart';
import '../../../model/component/fl_component_model.dart';

class FlHtmlTextFieldWidget<T extends FlTextFieldModel> extends FlStatelessDataWidget<T, String> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The [HtmlEditorController] of the [HtmlEditor] widget.
  final HtmlEditorController htmlController;

  /// The [Function] that is called when the focus of the [HtmlEditor] widget changes.
  final Function(bool pNewFocus) onFocusChanged;

  /// The maximum number of characters that can be entered in the [HtmlEditor] widget.
  final int? characterLimit;

  /// The [Function] that is called when the [HtmlEditor] widget is initialized.
  ///
  /// Only after the initialization is complete can the controller be used.
  final Function()? onInit;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlHtmlTextFieldWidget({
    super.key,
    required super.model,
    required super.valueChanged,
    required super.endEditing,
    required this.htmlController,
    required this.onFocusChanged,
    this.onInit,
    this.characterLimit,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return HtmlEditor(
      controller: htmlController,
      htmlEditorOptions: HtmlEditorOptions(
        hint: model.placeholder,
        darkMode: Theme.of(context).brightness == Brightness.dark,
        shouldEnsureVisible: false,
        adjustHeightForKeyboard: false,
        // Disabled: Only affects the startup of the widget.
        // Subsequent changes are not taken into account.
        // Must be handled via the controller.
        disabled: model.isReadOnly,
      ),
      callbacks: Callbacks(
          onFocus: () => onFocusChanged(true),
          onBlur: () => onFocusChanged(false),
          onInit: () {
            htmlController.setFullScreen();
            onInit?.call();
          }),
    );
  }
}
