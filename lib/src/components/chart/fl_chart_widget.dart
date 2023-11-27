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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

import '../../flutter_ui.dart';
import '../../model/component/fl_component_model.dart';
import '../base_wrapper/fl_stateless_widget.dart';

class FlChartWidget<T extends FlChartModel> extends FlStatelessWidget<T> {
  static const double _legendPadding = 30;

  final List<Map<String, dynamic>> data;
  final num highestValue;
  final num highestStackedValue;
  final StreamController<Selected?>? selectionStream;
  final bool showLegend;

  static const colors = [
    Color(0xffe41a1c),
    Color(0xff377eb8),
    Color(0xff4daf4a),
    Color(0xff984ea3),
    Color(0xffff7f00),
    Color(0xffffff33),
  ];

  static const colorsTransparent = [
    Color(0xc8e41a1c),
    Color(0xc8377eb8),
    Color(0xc84daf4a),
    Color(0xc8984ea3),
    Color(0xc8ff7f00),
    Color(0xc8ffff33),
  ];

  const FlChartWidget(
      {super.key,
      required super.model,
      required this.highestValue,
      required this.highestStackedValue,
      required this.data,
      this.selectionStream,
      this.showLegend = true});

  @override
  Widget build(BuildContext context) {
    Widget chart;

    if (data.isEmpty) {
      chart = Center(child: Text(FlutterUI.translate("No data to display")));
    }

    // There exist 4 types of "charts"
    // Line; Area; Bars; Horizontal Bars;

    if (model.isLineChart() || model.isAreaChart() || model.isBarChart()) {
      chart = _buildChart(context);
    } else if (model.isPieChart()) {
      chart = Center(child: Text(FlutterUI.translate("Pie Chart")));
    } else {
      chart = Center(child: Text(FlutterUI.translate("Unknown Chart")));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (model.title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              FlutterUI.translate(model.title),
              style: const TextStyle(fontSize: 24),
            ),
          ),
        Expanded(
          child: chart,
        ),
      ],
    );
  }

  /// Builds pie charts.
  Widget _buildPieChart({bool showLegend = true}) {
    if (model.yColumnNames.length == 1) {
      return Padding(
        padding: showLegend ? const EdgeInsets.only(bottom: _legendPadding) : EdgeInsets.zero,
        child: Chart<Map<String, dynamic>>(
          data: data,
          rebuild: true,
          variables: {
            "index": Variable(
              accessor: (e) => e["index"].toString(),
            ),
            "value": Variable(
              accessor: (e) => e["value"] as num,
            ),
          },
          transforms: [
            Proportion(
              variable: "value",
              as: 'percent',
            ),
          ],
          marks: [
            IntervalMark(
              position: Varset('percent') / Varset("index"),
              label: LabelEncode(
                encoder: (tuple) => Label(
                  "${tuple["index"]}: ${(tuple['percent'] * 100).round()}%",
                  LabelStyle(
                    align: Alignment.center,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xe6ffffff),
                    ),
                  ),
                ),
              ),
              color: ColorEncode(variable: "index", values: FlChartWidget.colors),
              modifiers: [StackModifier()],
              // selectionStream: selectionStream,
            ),
          ],
          coord: PolarCoord(
            transposed: true,
            dimCount: 1,
            startRadius: model.isStyle(FlChartModel.STYLE_RING) ? 0.80 : 0,
          ),
          // Selection broken, wrong Tooltip -> disabled
          // selections: {
          //   'select': PointSelection(
          //     on: {
          //       GestureType.tap,
          //     },
          //     clear: {
          //       GestureType.doubleTap,
          //     },
          //   ),
          // },
          // tooltip: TooltipGuide(
          //   multiTuples: true,
          //   offset: const Offset(-20, -20),
          //   align: Alignment.bottomRight,
          // ),
          // crosshair: CrosshairGuide(
          //   followPointer: [true, true],
          //   layer: 100,
          //   selections: {
          //     "touchMove",
          //     "select",
          //   },
          // ),
          annotations: showLegend
              ? [
                  if (model.yColumnNames.length > 1)
                    for (int i = 0; i < model.yColumnNames.length; i++)
                      ..._buildAnnotation(
                        i,
                        model.yColumnNames.length,
                        model.yColumnLabels[i],
                      ),
                  if (model.yColumnNames.length == 1)
                    for (int i = 0; i < data.length; i++)
                      ..._buildAnnotation(
                        i,
                        data.length,
                        data[i]["index"],
                      ),
                ]
              : null,
        ),
      );
    }

    return Padding(
      padding: showLegend ? const EdgeInsets.only(bottom: _legendPadding) : EdgeInsets.zero,
      child: Chart<Map<String, dynamic>>(
        data: data,
        rebuild: true,
        variables: {
          // "group": Variable(
          //   accessor: (e) => e["group"] as String,
          // ),
          "index": Variable(
            accessor: (e) => e["index"].toString(),
          ),
          "value": Variable(
            accessor: (e) => e["value"] as num,
          ),
        },
        transforms: [
          Proportion(
            variable: "value",
            as: 'percent',
          ),
        ],
        marks: [
          IntervalMark(
            position: Varset('percent') / Varset("index"),
            label: LabelEncode(
              encoder: (tuple) => Label(
                "${tuple["index"]}: ${(tuple['percent'] * 100).round()}%",
                LabelStyle(
                  align: Alignment.center,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xe6ffffff),
                  ),
                ),
              ),
            ),
            color: ColorEncode(variable: "index", values: FlChartWidget.colors),
            modifiers: [StackModifier()],
            // selectionStream: selectionStream,
          ),
        ],
        coord: PolarCoord(
          transposed: true,
          dimCount: 1,
          startRadius: model.isStyle(FlChartModel.STYLE_RING) ? 0.80 : 0,
        ),
        annotations: showLegend
            ? [
                if (model.yColumnNames.length > 1)
                  for (int i = 0; i < model.yColumnNames.length; i++)
                    ..._buildAnnotation(
                      i,
                      model.yColumnNames.length,
                      model.yColumnLabels[i],
                    ),
                if (model.yColumnNames.length == 1)
                  for (int i = 0; i < data.length; i++)
                    ..._buildAnnotation(
                      i,
                      data.length,
                      data[i]["index"],
                    ),
              ]
            : null,
      ),
    );

    return Padding(
      padding: showLegend ? const EdgeInsets.only(bottom: _legendPadding) : EdgeInsets.zero,
      child: Chart<Map<String, dynamic>>(
        data: data,
        rebuild: true,
        variables: {
          "index": Variable(
            accessor: (e) => e["index"].toString(),
          ),
          for (String yColumnName in model.yColumnNames)
            yColumnName: Variable(
              accessor: (e) => e[yColumnName] as num,
            ),
        },
        transforms: [
          for (String yColumnName in model.yColumnNames)
            Proportion(
              variable: yColumnName,
              as: 'percent_$yColumnName',
            ),
        ],
        marks: [
          for (String yColumnName in model.yColumnNames)
            IntervalMark(
              position: Varset('percent_$yColumnName') / Varset("index"),
              label: LabelEncode(
                encoder: (tuple) => Label(
                  "$yColumnName: ${(tuple['percent_$yColumnName'] * 100).round()}%",
                  LabelStyle(
                    align: Alignment.center,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xe6ffffff),
                    ),
                  ),
                ),
              ),
              color: ColorEncode(variable: yColumnName, values: FlChartWidget.colors),
              // modifiers: [StackModifier()],
              // selectionStream: selectionStream,
            ),
        ],
        coord: PolarCoord(
          transposed: true,
          dimCount: 1,
          startRadius: model.isStyle(FlChartModel.STYLE_RING) ? 0.80 : 0,
        ),
        annotations: showLegend
            ? [
                if (model.yColumnNames.length > 1)
                  for (int i = 0; i < model.yColumnNames.length; i++)
                    ..._buildAnnotation(
                      i,
                      model.yColumnNames.length,
                      model.yColumnLabels[i],
                    ),
                if (model.yColumnNames.length == 1)
                  for (int i = 0; i < data.length; i++)
                    ..._buildAnnotation(
                      i,
                      data.length,
                      data[i]["index"],
                    ),
              ]
            : null,
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Chart<Map<String, dynamic>>(
          data: data,
          variables: getVariables(),
          marks: getMarks(context, constraints),
          transforms: getPercentTransformIfNecessary(),
          coord: getCoordinateSystem(context),
          axes: getAxes(),
          selections: getSelections(),
        );
      },
    );
  }

  List<AxisGuide<dynamic>> getAxes() {
    return [
      Defaults.horizontalAxis,
      Defaults.verticalAxis,
    ];
  }

  /// Default variables for the charts.
  Map<String, Variable<Map<String, dynamic>, dynamic>> getVariables() {
    // Most graphs work with a linear scale for the index, but some charts need an ordinal scale
    // Linear is when the index is a num, ordinal is when the index is a string
    // Because "numbers" as a "string" are already correctly sorted, we can just always use an ordinal scale.
    // E.g. A - B - C will be sorted to numbers with an ordinal scale.
    // E.g. 1 - 2 - 3 will also be sorted correctly.
    return {
      "index": Variable(
        accessor: (map) => map["index"].toString(),
      ),
      "value": Variable(
        accessor: (map) => map["value"] as num,
        scale: LinearScale(min: 0, max: (model.isStackedChart() ? highestStackedValue : highestValue) * 1.05),
      ),
      "group": Variable(
        accessor: (map) => map["group"] as String,
      ),
    };
  }

  List<Mark> getMarks(BuildContext context, BoxConstraints constraints) {
    List<Mark> marks = [];

    if (model.isLineChart() || model.isAreaChart()) {
      marks.add(
        LineMark(
          position: getMarkPositions(),
          shape: ShapeEncode(value: BasicLineShape()),
          color: getColors(),
          layer: 1,
          modifiers: model.isStackedChart() ? [StackModifier()] : null,
        ),
      );

      if (model.isLineChart()) {
        marks.add(
          PointMark(
            position: getMarkPositions(),
            color: getColors(),
            layer: 2,
          ),
        );
      }
    }

    if (model.isAreaChart()) {
      AreaMark areaMark = AreaMark(
        position: getMarkPositions(),
        color: getTransparentColors(),
        modifiers: model.isStackedChart() ? [StackModifier()] : null,
        layer: 0,
      );

      marks.add(areaMark);
    }

    if (model.isBarChart()) {
      // 20 is the bottom padding and 40 is the left padding.
      int countOfBars = data.map((e) => e["index"]).toSet().length;

      double sizeToUse =
          (model.isHorizontalBarChart() ? constraints.maxHeight - 20 : constraints.maxWidth - 40) - countOfBars;
      double sizeOfOneBar = sizeToUse / countOfBars;

      int? countOfGroups;
      if (!model.isStackedChart() && !model.isOverlappedBarChart()) {
        // individual bars
        countOfGroups = data.map((e) => e["group"]).toSet().length;
        sizeOfOneBar = sizeOfOneBar / countOfGroups;
      }

      List<Modifier>? modifiers;

      if (model.isStackedChart()) {
        modifiers = [StackModifier()];
      } else if (!model.isOverlappedBarChart()) {
        modifiers = [DodgeModifier(symmetric: false)];
      }

      IntervalMark intervalMark = IntervalMark(
        position: getMarkPositions(),
        color: model.isOverlappedBarChart() ? getTransparentColors() : getColors(),
        size: SizeEncode(
          value: sizeOfOneBar,
        ),
        modifiers: modifiers,
        layer: 0,
      );

      marks.add(intervalMark);
    }

    return marks;
  }

  Varset getMarkPositions() {
    if (model.isPercentChart()) {
      return Varset("index") * Varset("percent") / Varset("group");
    }

    return Varset("index") * Varset("value") / Varset("group");
  }

  ColorEncode getTransparentColors() {
    return ColorEncode(
      variable: "group",
      values: colorsTransparent,
    );
  }

  ColorEncode getColors() {
    return ColorEncode(
      variable: "group",
      values: colors,
    );
  }

  Coord getCoordinateSystem(BuildContext context) {
    return RectCoord(
      transposed: model.isHorizontalBarChart(),
      color: Theme.of(context).colorScheme.background,
    );
  }

  List<VariableTransform>? getPercentTransformIfNecessary() {
    if (model.isPercentChart()) {
      return [
        Proportion(
          variable: "value",
          as: "percent",
          nest: Varset("index"),
        ),
      ];
    }
  }

  Map<String, Selection> getSelections() {
    return {
      'select': PointSelection(
        nearest: false,
        on: {
          GestureType.tap,
        },
        dim: Dim.x,
      )
    };
  }

  List<Annotation> _buildAnnotation(int i, int length, String label) {
    double getHorizontalPosition(Size size, int i, int length) => (size.width / (length + 1)) * (i + 1);

    return [
      CustomAnnotation(
        renderer: (_, size) => [
          CircleElement(
            center: Offset(getHorizontalPosition(size, i, length) - 10, size.height + 10),
            radius: 5,
            style: PaintStyle(fillColor: FlChartWidget.colors[i]),
          ),
        ],
        anchor: (p0) => const Offset(0, 0),
      ),
      TagAnnotation(
        label: Label(
          label,
          LabelStyle(textStyle: Defaults.textStyle, align: Alignment.centerRight),
        ),
        anchor: (size) => Offset(getHorizontalPosition(size, i, length), size.height + 10),
      ),
    ];
  }
}
