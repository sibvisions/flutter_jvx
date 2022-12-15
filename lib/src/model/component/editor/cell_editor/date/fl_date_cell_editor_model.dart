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

import '../../../../../service/api/shared/api_object_property.dart';
import '../cell_editor_model.dart';

class FlDateCellEditorModel extends ICellEditorModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  String dateFormat = "d. MMMM yyyy HH:mm";

  String? timeZoneCode;

  String? locale;

  bool isDateEditor = true;

  bool isTimeEditor = true;

  bool isHourEditor = true;

  bool isMinuteEditor = true;

  bool isSecondEditor = false;

  bool isAmPmEditor = false;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlDateCellEditorModel get defaultModel => FlDateCellEditorModel();

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    dateFormat = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.dateFormat,
      pDefault: defaultModel.dateFormat,
      pCurrent: dateFormat,
      pConversion: (value) => value.replaceAll("Y", "y"),
    );

    timeZoneCode = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.timeZone,
      pDefault: defaultModel.timeZoneCode,
      pCurrent: timeZoneCode,
    );

    locale = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.locale,
      pDefault: defaultModel.locale,
      pCurrent: locale,
    );

    isDateEditor = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.isDateEditor,
      pDefault: defaultModel.isDateEditor,
      pCurrent: isDateEditor,
    );
    isTimeEditor = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.isTimeEditor,
      pDefault: defaultModel.isTimeEditor,
      pCurrent: isTimeEditor,
    );

    isHourEditor = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.isHourEditor,
      pDefault: defaultModel.isHourEditor,
      pCurrent: isHourEditor,
    );

    isMinuteEditor = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.isMinuteEditor,
      pDefault: defaultModel.isMinuteEditor,
      pCurrent: isMinuteEditor,
    );

    isSecondEditor = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.isSecondEditor,
      pDefault: defaultModel.isSecondEditor,
      pCurrent: isSecondEditor,
    );
    isAmPmEditor = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.isAmPmEditor,
      pDefault: defaultModel.isAmPmEditor,
      pCurrent: isAmPmEditor,
    );
  }
}
