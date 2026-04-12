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
  void applyFromJson(Map<String, dynamic> newJson) {
    super.applyFromJson(newJson);

    title = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.title,
      defaultValue: title,
      currentValue: title,
    );

    maxValue = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.maxValue,
      defaultValue: maxValue,
      currentValue: maxValue,
    );

    minValue = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.minValue,
      defaultValue: minValue,
      currentValue: minValue,
    );

    maxErrorValue = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.maxErrorValue,
      defaultValue: maxErrorValue,
      currentValue: maxErrorValue,
    );

    minErrorValue = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.minErrorValue,
      defaultValue: minErrorValue,
      currentValue: minErrorValue,
    );

    maxWarningValue = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.maxWarningValue,
      defaultValue: maxWarningValue,
      currentValue: maxWarningValue,
    );

    minWarningValue = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.minWarningValue,
      defaultValue: minWarningValue,
      currentValue: minWarningValue,
    );

    dataProvider = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.dataRow,
      defaultValue: dataProvider,
      currentValue: dataProvider,
    );

    gaugeStyle = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.gaugeStyle,
      defaultValue: gaugeStyle,
      currentValue: gaugeStyle,
    );

    value = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.data,
      defaultValue: value,
      currentValue: value,
      conversion: (conv) => conv.toDouble(),
    );

    columnLabel = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.columnLabel,
      defaultValue: columnLabel,
      currentValue: columnLabel,
    );
  }
}
