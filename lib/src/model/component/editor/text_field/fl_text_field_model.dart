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
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The style if the text editor should copy option
  static const String STYLE_COPY = "f_copy";


  /// the enter key completion
  static const String ENTER_KEY = "ENTER_KEY";

  /// the focus lost completion
  static const String FOCUS_LOST = "FOCUS_LOST";

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
  bool get hideClearIcon => styles.contains(FlComponentModel.STYLE_NO_CLEAR_ICON);

  /// If this editor should show copy
  bool get showCopy => styles.contains(STYLE_COPY);

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
  void applyFromJson(Map<String, dynamic> newJson) {
    super.applyFromJson(newJson);

    placeholder = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.placeholder,
      defaultValue: defaultModel.placeholder,
      currentValue: placeholder,
    );

    rows = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.rows,
      defaultValue: defaultModel.rows,
      currentValue: rows,
    );

    columns = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.columns,
      defaultValue: defaultModel.columns,
      currentValue: columns,
    );

    isBorderVisible = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.borderVisible,
      defaultValue: defaultModel.isBorderVisible,
      currentValue: isBorderVisible,
    );

    isEditable = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.editable,
      defaultValue: defaultModel.isEditable,
      currentValue: isEditable,
    );
  }

  @override
  void applyCellEditorOverrides(Map<String, dynamic> json) {
    super.applyCellEditorOverrides(json);

    Map<String, dynamic> overrideJson = {};

    if (json.containsKey(ApiObjectProperty.cellEditorPlaceholder)) {
      overrideJson[ApiObjectProperty.placeholder] = json[ApiObjectProperty.cellEditorPlaceholder];
    }

    if (overrideJson.isNotEmpty) {
      applyFromJson(overrideJson);
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// If editing of the text field is possible.
  bool get isReadOnly {
    return !isEnabled || !isEditable;
  }
}
