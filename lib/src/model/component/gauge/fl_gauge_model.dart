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

class FlGaugeModel extends FlComponentModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  String title = "";

  String dataProvider = "";
  double maxValue = 1;
  double minValue = 0;
  double? maxErrorValue;
  double? minErrorValue;
  double? maxWarningValue;
  double? minWarningValue;
  int gaugeStyle = 0;
  double value = 0;
  String? columnLabel = "";

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlGaugeModel() : super() {
    preferredSize = const Size(300, 300);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlGaugeModel get defaultModel => FlGaugeModel();

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    title = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.title,
      pDefault: title,
      pCurrent: title,
    );

    maxValue = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.maxValue,
      pDefault: maxValue,
      pCurrent: maxValue,
    );

    minValue = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.minValue,
      pDefault: minValue,
      pCurrent: minValue,
    );

    maxErrorValue = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.maxErrorValue,
      pDefault: maxErrorValue,
      pCurrent: maxErrorValue,
    );

    minErrorValue = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.minErrorValue,
      pDefault: minErrorValue,
      pCurrent: minErrorValue,
    );

    maxWarningValue = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.maxWarningValue,
      pDefault: maxWarningValue,
      pCurrent: maxWarningValue,
    );

    minWarningValue = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.minWarningValue,
      pDefault: minWarningValue,
      pCurrent: minWarningValue,
    );

    dataProvider = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.dataRow,
      pDefault: dataProvider,
      pCurrent: dataProvider,
    );

    gaugeStyle = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.gaugeStyle,
      pDefault: gaugeStyle,
      pCurrent: gaugeStyle,
    );

    value = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.data,
      pDefault: value,
      pCurrent: value,
      pConversion: (conv) => conv.toDouble(),
    );

    columnLabel = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.columnLabel,
      pDefault: columnLabel,
      pCurrent: columnLabel,
    );
  }
}
