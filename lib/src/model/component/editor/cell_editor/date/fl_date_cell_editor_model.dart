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
  void applyFromJson(Map<String, dynamic> newJson) {
    super.applyFromJson(newJson);

    dateFormat = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.dateFormat,
      defaultValue: defaultModel.dateFormat,
      currentValue: dateFormat,
      conversion: (value) => value.replaceAll("Y", "y"),
    );

    timeZoneCode = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.timeZone,
      defaultValue: defaultModel.timeZoneCode,
      currentValue: timeZoneCode,
    );

    locale = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.locale,
      defaultValue: defaultModel.locale,
      currentValue: locale,
    );

    isDateEditor = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.isDateEditor,
      defaultValue: defaultModel.isDateEditor,
      currentValue: isDateEditor,
    );
    isTimeEditor = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.isTimeEditor,
      defaultValue: defaultModel.isTimeEditor,
      currentValue: isTimeEditor,
    );

    isHourEditor = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.isHourEditor,
      defaultValue: defaultModel.isHourEditor,
      currentValue: isHourEditor,
    );

    isMinuteEditor = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.isMinuteEditor,
      defaultValue: defaultModel.isMinuteEditor,
      currentValue: isMinuteEditor,
    );

    isSecondEditor = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.isSecondEditor,
      defaultValue: defaultModel.isSecondEditor,
      currentValue: isSecondEditor,
    );
    isAmPmEditor = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.isAmPmEditor,
      defaultValue: defaultModel.isAmPmEditor,
      currentValue: isAmPmEditor,
    );
  }
}
