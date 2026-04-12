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

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  @override
  FlCheckBoxCellEditorModel get defaultModel => FlCheckBoxCellEditorModel();

  Set<String> _parseStyle(dynamic style) {
    String sStyle = (style as String);

    return sStyle.split(",").toSet();
  }

  @override
  void applyFromJson(Map<String, dynamic> newJson) {
    super.applyFromJson(newJson);

    // ContentType
    selectedValue = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.selectedValue,
      defaultValue: defaultModel.selectedValue,
      currentValue: selectedValue,
    );

    deselectedValue = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.deselectedValue,
      defaultValue: defaultModel.deselectedValue,
      currentValue: deselectedValue,
    );

    text = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.text,
      defaultValue: defaultModel.text,
      currentValue: text,
    );

    imageName = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.imageName,
      defaultValue: defaultModel.imageName,
      currentValue: imageName,
    );

    styles = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.style,
      defaultValue: defaultModel.styles,
      conversion: _parseStyle,
      currentValue: {},
    );
  }
}
