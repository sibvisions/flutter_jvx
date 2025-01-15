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

class FlTextFieldModel extends FlLabelModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The placeholder text inside the text field if it is empty.
  String? placeholder;

  // The count of rows of text shown.
  int rows = 1;

  /// The average amount of characters to be seen when unconstrained.
  /// (average character length * columns = wanted width of field in non constrained layouts)
  int columns = 10;

  /// If the text field has a drawn border.
  bool isBorderVisible = true;

  /// If the text field is editable or not.
  bool isEditable = true;

  /// If this editor should have a clear icon.
  bool get hideClearIcon => styles.contains(FlComponentModel.NO_CLEAR_ICON_STYLE);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlTextFieldModel() : super() {
    verticalAlignment = VerticalAlignment.CENTER;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlTextFieldModel get defaultModel => FlTextFieldModel();

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    placeholder = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.placeholder,
      pDefault: defaultModel.placeholder,
      pCurrent: placeholder,
    );

    rows = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.rows,
      pDefault: defaultModel.rows,
      pCurrent: rows,
    );

    columns = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.columns,
      pDefault: defaultModel.columns,
      pCurrent: columns,
    );

    isBorderVisible = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.borderVisible,
      pDefault: defaultModel.isBorderVisible,
      pCurrent: isBorderVisible,
    );

    isEditable = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.editable,
      pDefault: defaultModel.isEditable,
      pCurrent: isEditable,
    );
  }

  @override
  void applyCellEditorOverrides(Map<String, dynamic> pJson) {
    super.applyCellEditorOverrides(pJson);

    Map<String, dynamic> overrideJson = {};
    if (pJson.containsKey(ApiObjectProperty.cellEditorEditable)) {
      overrideJson[ApiObjectProperty.editable] = pJson[ApiObjectProperty.cellEditorEditable];
    }
    if (pJson.containsKey(ApiObjectProperty.cellEditorPlaceholder)) {
      overrideJson[ApiObjectProperty.placeholder] = pJson[ApiObjectProperty.cellEditorPlaceholder];
    }

    applyFromJson(overrideJson);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// If editing of the text field is possible.
  bool get isReadOnly {
    return !isEnabled || !isEditable;
  }
}
