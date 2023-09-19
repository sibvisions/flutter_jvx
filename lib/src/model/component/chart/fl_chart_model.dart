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

class FlChartModel extends FlComponentModel {
  /// Style constant for showing a line chart.
  static const int STYLE_LINES = 0;

  /// Style constant for showing an area chart.
  static const int STYLE_AREA = 1;

  /// Style constant for showing a bar chart.
  static const int STYLE_BARS = 2;

  /// Style constant for showing a pie chart.
  static const int STYLE_PIE = 3;

  /// Style constant for showing an step line chart.
  static const int STYLE_STEPLINES = 100;

  /// Style constant for showing an area chart.
  static const int STYLE_STACKEDAREA = 101;

  /// Style constant for showing an area chart.
  static const int STYLE_STACKEDPERCENTAREA = 201;

  /// Style constant for showing a stacked bar chart.
  static const int STYLE_STACKEDBARS = 102;

  /// Style constant for showing a stacked bar chart.
  static const int STYLE_STACKEDPERCENTBARS = 202;

  /// Style constant for showing a overlapped bar chart.
  static const int STYLE_OVERLAPPEDBARS = 302;

  /// Style constant for showing a bar chart.
  static const int STYLE_HBARS = 1002;

  /// Style constant for showing a stacked bar chart.
  static const int STYLE_STACKEDHBARS = 1102;

  /// Style constant for showing a stacked bar chart.
  static const int STYLE_STACKEDPERCENTHBARS = 1202;

  /// Style constant for showing a overlapped bar chart.
  static const int STYLE_OVERLAPPEDHBARS = 1302;

  /// Style constant for showing a ring chart.
  static const int STYLE_RING = 103;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  String xAxisTitle = "";
  String yAxisTitle = "";
  String xColumnName = "";
  List<String> yColumnNames = [];
  List yColumnLabels = [];
  String xColumnLabel = "";
  String title = "";
  int chartStyle = 0;

  String dataProvider = "";

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlChartModel() : super() {
    preferredSize = const Size(100, 100);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlChartModel get defaultModel => FlChartModel();

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    xAxisTitle = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.xAxisTitle,
      pDefault: defaultModel.xAxisTitle,
      pCurrent: xAxisTitle,
    );

    yAxisTitle = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.yAxisTitle,
      pDefault: defaultModel.yAxisTitle,
      pCurrent: yAxisTitle,
    );
    xColumnName = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.xColumnName,
      pDefault: defaultModel.xColumnName,
      pCurrent: xColumnName,
    );

    yColumnNames = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.yColumnNames,
      pDefault: defaultModel.yColumnNames,
      pCurrent: yColumnNames,
      pConversion: (value) => List<String>.from(value),
    );

    title = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.title,
      pDefault: defaultModel.title,
      pCurrent: title,
    );

    yColumnLabels = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.yColumnLabels,
      pDefault: defaultModel.yColumnLabels,
      pCurrent: yColumnLabels,
      pConversion: (value) => List<String>.from(value),
    );

    xColumnLabel = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.xColumnLabel,
      pDefault: defaultModel.xColumnLabel,
      pCurrent: xColumnLabel,
    );
    dataProvider = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.dataBook,
      pDefault: defaultModel.dataProvider,
      pCurrent: dataProvider,
    );
    chartStyle = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.chartStyle,
      pDefault: defaultModel.chartStyle,
      pCurrent: chartStyle,
    );
  }

  bool isStyle(int chartStyle) {
    return this.chartStyle == chartStyle;
  }

  bool matchesStyles(List<int> chartStyles) {
    return chartStyles.contains(chartStyle);
  }

  bool isPieChart() {
    return matchesStyles(const [
      FlChartModel.STYLE_PIE,
      FlChartModel.STYLE_RING,
    ]);
  }

  bool isHorizontalBarStyle() {
    return matchesStyles(const [
      FlChartModel.STYLE_HBARS,
      FlChartModel.STYLE_STACKEDHBARS,
      FlChartModel.STYLE_STACKEDPERCENTHBARS,
      FlChartModel.STYLE_OVERLAPPEDHBARS,
    ]);
  }
}
