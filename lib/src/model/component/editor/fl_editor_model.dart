/* Copyright 2022 SIB Visions GmbH
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

import '../../../service/api/shared/api_object_property.dart';
import '../../../util/parse_util.dart';
import '../fl_component_model.dart';
import '../interface/i_data_model.dart';

class FlEditorModel extends FlComponentModel implements IDataModel {
  bool changedCellEditor = false;

  @override
  String dataProvider = "";

  String columnName = "";

  Map<String, dynamic> json = {};

  // ICellEditor cellEditor = FlDummyCellEditor(pCellEditorJson: {});

  FlEditorModel();

  @override
  FlEditorModel get defaultModel => FlEditorModel();

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    // We have to give the editor wrapper all the necessary informations for the layout.
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

    changedCellEditor = pJson.keys.contains(ApiObjectProperty.cellEditor);
  }

  /// Applies component specific layout size information
  applyComponentInformation(FlComponentModel pComponentModel) {
    preferredSize ??= pComponentModel.preferredSize;
    minimumSize ??= pComponentModel.minimumSize;
    maximumSize ??= pComponentModel.maximumSize;
  }
}
