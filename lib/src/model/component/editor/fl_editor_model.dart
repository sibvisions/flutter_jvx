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

class FlEditorModel extends FlComponentModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// If the last change to this model changed the editor.
  bool changedCellEditor = false;

  /// The data provider of the editor.
  String dataProvider = "";

  /// The column name of the editor.
  String columnName = "";

  /// The json of the editor.
  Map<String, dynamic> json = {};

  /// If the editor should save immediately.
  bool savingImmediate = false;

  /// If this editor should have a clear icon.
  bool get hideClearIcon => styles.contains(FlComponentModel.STYLE_NO_CLEAR_ICON);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlEditorModel();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlEditorModel get defaultModel => FlEditorModel();

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    // We have to give the editor wrapper all the necessary information for the layout.
    super.applyFromJson(pJson);

    ParseUtil.applyJsonToJson(pJson, json);

    columnName = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.columnName,
      pDefault: defaultModel.columnName,
      pCurrent: columnName,
    );

    dataProvider = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.dataRow,
      pDefault: defaultModel.dataProvider,
      pCurrent: dataProvider,
    );

    savingImmediate = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.savingImmediate,
      pDefault: defaultModel.savingImmediate,
      pCurrent: savingImmediate,
    );

    changedCellEditor = pJson.keys.contains(ApiObjectProperty.cellEditor);
  }

  /// Applies component specific layout size information
  applyComponentInformation(FlComponentModel pComponentModel) {
    preferredSize ??= pComponentModel.preferredSize;
    minimumSize ??= pComponentModel.minimumSize;
    maximumSize ??= pComponentModel.maximumSize;
  }
}
