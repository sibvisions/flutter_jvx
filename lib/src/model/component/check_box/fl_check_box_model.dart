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

  /// The styles to make the checkbox to a switch.
  static const String STYLE_SWITCH = "f_switch";

  static const String STYLE_CELL_SWITCH = "ui-switch";

  /// The style to make the checkbox to a checkbox.
  ///
  /// This serves as an override to allow editors to override a switch style,
  /// allowing a cell editor to be a switch inside a table,
  /// and the cell editor to be overridden by an editor style.
  static const String STYLE_CHECKBOX = "f_checkbox";

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // Checkbox never draws a border.
  @override
  bool get borderPainted =>
      styles.contains(ButtonCellEditorStyles.BUTTON) || styles.contains(ButtonCellEditorStyles.TOGGLEBUTTON);

  @override
  FlCheckBoxModel get defaultModel => FlCheckBoxModel();

  bool get isSwitch =>
      (styles.contains(STYLE_SWITCH) || styles.contains(STYLE_CELL_SWITCH)) && !styles.contains(STYLE_CHECKBOX);

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
