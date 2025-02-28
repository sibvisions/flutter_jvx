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
part of 'package:flutter_jvx/src/model/component/fl_component_model.dart';

/// The model of a checkbox
class FlCheckBoxModel extends FlRadioButtonModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The styles to make the checkbox to a switch (backwards compatibility).
  static const String STYLE_SWITCH = "f_switch";

  /// The style to make the checkbox to a checkbox.
  ///
  /// This serves as an override to allow editors to override a switch style,
  /// allowing a cell editor to be a switch inside a table,
  /// and the cell editor to be overridden by an editor style.
  static const String STYLE_CHECKBOX = "f_checkbox";

  static const String STYLE_UI_BUTTON = "ui-button";
  static const String STYLE_UI_RADIOBUTTON = "ui-radiobutton";
  static const String STYLE_UI_TOGGLEBUTTON = "ui-togglebutton";
  static const String STYLE_UI_SWITCH = "ui-switch";
  static const String STYLE_UI_HYPERLINK = "ui-hyperlink";

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // Checkbox never draws a border.
  @override
  bool get borderPainted =>
      styles.contains(STYLE_UI_BUTTON) || styles.contains(STYLE_UI_TOGGLEBUTTON);

  @override
  FlCheckBoxModel get defaultModel => FlCheckBoxModel();

  bool get isSwitch =>
      (styles.contains(STYLE_SWITCH) || styles.contains(STYLE_UI_SWITCH)) && !styles.contains(STYLE_CHECKBOX);

  /// The image of a checkbox
  String? imageName;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlCheckBoxModel() : super() {
    paddings = const EdgeInsets.all(2);
    horizontalAlignment = HorizontalAlignment.LEFT;
  }
}
