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

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

import '../../components.dart';
import '../../flutter_ui.dart';
import '../../model/component/fl_component_model.dart';
import '../../util/jvx_colors.dart';

class FlChartWidget<T extends FlChartModel> extends FlStatelessWidget<T> {
  final List<Map<String, dynamic>> data;
  final num highestValue;
  final num highestStackedValue;
  final StreamController<Selected?>? selectionStream;

  static const colors = [
    Color(0xff81dfd0),
    Color(0xffb6afe4),
    Color(0xfff95a48),
    Color(0xff67b3e9),
    Color(0xfffca745),
    Color(0xffabec3c),
    Color(0xfff99fce),
    Color(0xffbc80bd),
    Color(0xffccebc5),
    Color(0xffffed6f),
    Color(0xffb22222),
    Color(0xff377eb8),
    Color(0xff2f772d),
    Color(0xff874791),
    Color(0xffa4631f),
    Color(0xffa05195),
    Color(0xffffa600),
    Color(0xfff95d6a),
    Color(0xff003f5c),
    Color(0xffd45087),
  ];

  static const colorsTransparent = [
    Color(0xc881dfd0),
    Color(0xc8b6afe4),
    Color(0xc8f95a48),
    Color(0xc867b3e9),
    Color(0xc8fca745),
    Color(0xc8abec3c),
    Color(0xc8f99fce),
    Color(0xc8bc80bd),
    Color(0xc8ccebc5),
    Color(0xc8ffed6f),
    Color(0xc8b22222),
    Color(0xc8377eb8),
    Color(0xc82f772d),
    Color(0xc8874791),
    Color(0xc8a4631f),
    Color(0xc8a05195),
    Color(0xc8ffa600),
    Color(0xc8f95d6a),
    Color(0xc8003f5c),
    Color(0xc8d45087),
  ];

  const FlChartWidget({
    super.key,
    required super.model,
    required this.highestValue,
    required this.highestStackedValue,
    required this.data,
    this.selectionStream,
  });

  @override
  Widget build(BuildContext context) {
    Widget chart;

    if (data.isEmpty) {
      chart = Center(child: Text(FlutterUI.translate("No data to display")));
    }

    // There exist 4 types of "charts"
    // Line; Area; Bars; Horizontal Bars;
    if (model.isLineChart() || model.isAreaChart() || model.isBarChart() || model.isPieChart()) {
      chart = _buildChart(context);
    } else {
      chart = Center(
        child: Text(
          FlutterUI.translate("Unknown Chart"),
        ),
      );
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
        _buildLegend(context),
      ],
    );
  }

  Widget _buildChart(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Chart<Map<String, dynamic>>(
          //required for repaint problems
          key: GlobalObjectKey("${model.id}_chartWidget"),
          data: data,
          variables: createVariables(),
          marks: createMarks(context, constraints),
          transforms: createPercentTransformIfNecessary(),
          coord: createCoordinateSystem(context),
          axes: createAxes(),
          selections: createSelections(),
        );
      },
    );
  }

  List<AxisGuide<dynamic>>? createAxes() {
    if (model.isPieChart()) {
      return null;
    }

    // Must switch them for horizontal bar charts
    // Otherwise the label offset is wrong
    if (model.isHorizontalBarChart()) {
      return [
        Defaults.verticalAxis,
        Defaults.horizontalAxis,
      ];
    }

    return [
      Defaults.horizontalAxis,
      Defaults.verticalAxis,
    ];
  }

  /// Default variables for the charts.
  Map<String, Variable<Map<String, dynamic>, dynamic>> createVariables() {
    if (model.isPieChart()) {
      return {
        "index": Variable(
          accessor: (map) => map["index"].toString(),
        ),
        "value": Variable(
          accessor: (map) => map["value"] as num,
          // scale: LinearScale(
          //   min: 0,
          //   max: highestStackedValue,
          //   title: model.yAxisTitle,
          // ),
        ),
      };
    }

    // Most graphs work with a linear scale for the index, but some charts need an ordinal scale
    // Linear is when the index is a num, ordinal is when the index is a string
    // Because "numbers" as a "string" are already correctly sorted, we can just always use an ordinal scale.
    // E.g. A - B - C will be sorted to numbers with an ordinal scale.
    // E.g. 1 - 2 - 3 will also be sorted correctly.
    return {
      "index": Variable(
        accessor: (map) => map["index"].toString(),
        scale: OrdinalScale(title: model.xAxisTitle),
      ),
      "value": Variable(
        accessor: (map) => map["value"] as num,
        scale: LinearScale(
          min: 0,
          max: (model.isStackedChart() ? highestStackedValue : highestValue) * 1.05,
          title: model.yAxisTitle,
        ),
      ),
      "group": Variable(
        accessor: (map) => map["group"] as String,
      ),
    };
  }

  List<Mark> createMarks(BuildContext context, BoxConstraints constraints) {
    List<Mark> marks = [];

    if (model.isLineChart()) {
      marks.add(LineMark(color: getColors()));

      marks.add(PointMark(color: getColors(), selectionStream: selectionStream));
    }

    if (model.isAreaChart()) {
      marks.add(LineMark(color: getColors()));
      marks.add(AreaMark(selectionStream: selectionStream));
    }

    if (model.isBarChart()) {
      // 20 is the bottom padding and 40 is the left padding.
      int countOfBars = data.map((e) => e["index"]).toSet().length;

      double sizeToUse;
      if (model.isHorizontalBarChart()) {
        sizeToUse = constraints.maxHeight - 20;
        sizeToUse = sizeToUse * 0.95; // same as the vertical range in the rect coord
      } else {
        sizeToUse = constraints.maxWidth - 40;
      }

      // space between the bars
      sizeToUse -= countOfBars;
      double sizeOfOneBar = sizeToUse / countOfBars;

      int? countOfGroups;
      if (!model.isStackedChart() && !model.isOverlappedBarChart()) {
        // individual bars
        countOfGroups = data.map((e) => e["group"]).toSet().length;
        sizeOfOneBar = sizeOfOneBar / countOfGroups;
      }

      IntervalMark intervalMark = IntervalMark(
        size: SizeEncode(
          value: sizeOfOneBar,
        ),
        modifiers: !model.isStackedChart() && !model.isOverlappedBarChart() ? [DodgeModifier(symmetric: false)] : null,
        selectionStream: selectionStream,
      );

      marks.add(intervalMark);
    }

    if (model.isPieChart()) {
      marks.add(
        IntervalMark(
          label: LabelEncode(
            encoder: (tuple) {
              int value;
              if (tuple.containsKey("percent")) {
                value = (tuple["percent"] * 100).round();
              } else {
                value = tuple["value"];
              }

              return Label(
                "$value%",
                LabelStyle(
                  textStyle: Defaults.textStyle.copyWith(color: JVxColors.DARKER_WHITE),
                  align: Alignment.center,
                ),
              );
            },
          ),
          modifiers: [StackModifier()],
          selectionStream: selectionStream,
        ),
      );
    }

    for (Mark mark in marks) {
      mark.position ??= getMarkPositions();
      mark.color ??= getTransparentColors();
      mark.modifiers ??= model.isStackedChart() ? [StackModifier()] : null;
    }

    return marks;
  }

  Varset? getMarkPositions() {
    if (model.isPieChart()) {
      // The pie chart only has one dimension, so we must "divide" like the groups.
      // This way we get another value inside the one dimension.
      return Varset("percent") / Varset("index");
    }

    if (model.isPercentChart()) {
      return Varset("index") * Varset("percent") / Varset("group");
    }

    return Varset("index") * Varset("value") / Varset("group");
  }

  ColorEncode getTransparentColors() {
    return ColorEncode(
      variable: model.isPieChart() ? "index" : "group",
      values: colorsTransparent,
    );
  }

  ColorEncode getColors() {
    return ColorEncode(
      variable: model.isPieChart() ? "index" : "group",
      values: colors,
    );
  }

  Coord createCoordinateSystem(BuildContext context) {
    if (model.isPieChart()) {
      return PolarCoord(
        // Makes the rose chart to a pie chart.
        transposed: true,
        // dimCount 1, Otherwise each group would be a different ring.
        dimCount: 1,
        startRadius: model.isStyle(FlChartModel.STYLE_RING) ? 0.80 : null,
      );
    }

    return RectCoord(
      transposed: model.isHorizontalBarChart(),
      verticalRange: model.isHorizontalBarChart() ? [0, 0.95] : null,
      color: Theme.of(context).colorScheme.background,
    );
  }

  List<VariableTransform>? createPercentTransformIfNecessary() {
    if (model.isPercentChart()) {
      return [
        Proportion(
          variable: "value",
          as: "percent",
          nest: Varset("index"),
        ),
      ];
    } else if (model.isPieChart()) {
      return [
        Proportion(
          variable: "value",
          as: "percent",
        ),
      ];
    }

    return null;
  }

  Map<String, Selection>? createSelections() {
    if (!kDebugMode) {
      // Disable the selection in release mode for now.
      return null;
    }

    if (model.isBarChart()) {
      return {
        'index': PointSelection(
          nearest: false,
          on: {
            GestureType.tap,
          },
          dim: Dim.x,
          variable: "index",
        ),
        'value': PointSelection(
          nearest: false,
          on: {
            GestureType.tap,
          },
          dim: Dim.x,
          variable: "value",
        ),
      };
    }

    if (model.isPieChart()) {
      return {
        'index': PointSelection(
          nearest: false,
          on: {
            GestureType.tap,
          },
          dim: Dim.y,
          variable: "index",
        ),
        'value': PointSelection(
          nearest: false,
          on: {
            GestureType.tap,
          },
          dim: Dim.y,
          variable: "value",
        ),
      };
    }

    return {
      'index': PointSelection(
        nearest: false,
        on: {
          GestureType.tap,
        },
        variable: "index",
      ),
      'value': PointSelection(
        nearest: false,
        on: {
          GestureType.tap,
        },
        variable: "value",
      ),
    };
  }

  Widget _buildLegend(BuildContext context) {
    List<String> labels;
    if (model.isPieChart() && model.yColumnLabels.length == 1) {
      labels = data.map((e) => e["index"].toString()).toList();
    } else {
      labels = model.yColumnLabels;
    }

    const double padding = 5;
    const double circleSize = 10;

    List<Widget> children = labels
        .mapIndexed(
          (index, label) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  color: colors[index],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: padding),
              Text(
                FlutterUI.translate(label),
                style: Defaults.textStyle,
              ),
            ],
          ),
        )
        .toList();

    return Padding(
      padding: const EdgeInsets.all(padding),
      child: Wrap(
        alignment: WrapAlignment.center,
        clipBehavior: Clip.hardEdge,
        runSpacing: padding,
        spacing: padding,
        children: children,
      ),
    );
  }
}
