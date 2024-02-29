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

import '../../../../components/editor/cell_editor/button_cell_editor_styles.dart';
import '../../../../service/api/shared/api_object_property.dart';
import 'cell_editor_model.dart';

class FlCheckBoxCellEditorModel extends ICellEditorModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The value to send if selected.
  dynamic selectedValue;

  /// The value to send if deselected.
  dynamic deselectedValue;

  /// The text to show next to the checkbox.
  String text = "";

  /// The image of a checkbox
  String imageName = "";

  /// True, if the component is a button
  bool isButton = false;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  @override
  FlCheckBoxCellEditorModel get defaultModel => FlCheckBoxCellEditorModel();

  Set<String> _parseStyle(dynamic pStyle) {
    String sStyle = (pStyle as String);

    return sStyle.split(",").toSet();
  }

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    // ContentType
    selectedValue = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.selectedValue,
      pDefault: defaultModel.selectedValue,
      pCurrent: selectedValue,
    );

    deselectedValue = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.deselectedValue,
      pDefault: defaultModel.deselectedValue,
      pCurrent: deselectedValue,
    );

    text = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.text,
      pDefault: defaultModel.text,
      pCurrent: text,
    );

    imageName = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.imageName,
      pDefault: defaultModel.imageName,
      pCurrent: imageName,
    );

    styles = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.style,
      pDefault: defaultModel.styles,
      pConversion: _parseStyle,
      pCurrent: {},
    );

    isButton =
        styles.any((style) => style == ButtonCellEditorStyles.BUTTON || style == ButtonCellEditorStyles.HYPERLINK);
  }
}
