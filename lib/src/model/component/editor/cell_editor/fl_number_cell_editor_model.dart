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

class FlNumberCellEditorModel extends ICellEditorModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  String numberFormat = "";

  String? locale;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  @override
  FlNumberCellEditorModel get defaultModel => FlNumberCellEditorModel();

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    numberFormat = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.numberFormat,
      pDefault: defaultModel.numberFormat,
      pCurrent: numberFormat,
    );

    locale = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.locale,
      pDefault: defaultModel.locale,
      pCurrent: locale,
    );
  }
}
