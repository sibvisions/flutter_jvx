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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
// ignore: implementation_imports
import 'package:graphic/src/encode/color.dart';

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
  final bool indexAreCategory;

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

  const FlChartWidget({
    super.key,
    required super.model,
    required this.highestValue,
    required this.highestStackedValue,
    required this.data,
    this.selectionStream,
    this.showLegend = true,
    this.indexAreCategory = false,
  });

  @override
  Widget build(BuildContext context) {
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
        Expanded(child: _buildChart(context)),
      ],
    );
  }

  Widget _buildChart(BuildContext context) {
    if (data.isEmpty) {
      return Center(child: Text(FlutterUI.translate("No data to display")));
    }

    // There exist 4 types of "charts"
    // Line; Area; Bars; Horizontal Bars;

    if (model.isLineChart()) {
      return _buildLineChart(context);
    } else if (model.isAreaChart()) {
      return _buildAreaChart(context);
    } else if (model.isBarChart()) {
      if (model.isHorizontalBarChart()) {
        return Center(child: Text(FlutterUI.translate("H Bar Chart")));
      } else {
        return Center(child: Text(FlutterUI.translate("Bar Chart")));
      }
    } else if (model.isPieChart()) {
      return Center(child: Text(FlutterUI.translate("Pie Chart")));
    } else {
      return Center(child: Text(FlutterUI.translate("Unknown Chart")));
    }
  }

  /// Builds the generic charts.
  ///
  /// Colors are mixed!
  Widget _buildGenericChart({bool showLegend = false}) {
    return Padding(
      padding: showLegend ? const EdgeInsets.only(bottom: _legendPadding) : EdgeInsets.zero,
      child: Chart<Map<String, dynamic>>(
        data: data,
        rebuild: true,
        variables: {
          "index": Variable(
            accessor: (e) => e["index"] as num,
          ),
          for (String yColumnName in model.yColumnNames)
            yColumnName: Variable(
              accessor: (e) => e[yColumnName] as num,
              scale:
                  LinearScale(max: model.isStyle(FlChartModel.STYLE_OVERLAPPEDBARS) ? highestValue + 1 : highestValue),
            ),
        },
        marks: [
          for (String yColumnName in model.yColumnNames)
            ..._createMark(
              model.chartStyle,
              model.yColumnNames.length - model.yColumnNames.indexOf(yColumnName),
              yColumnName,
            ),
        ],
        transforms: model.matchesStyles(const [
          FlChartModel.STYLE_STACKEDPERCENTAREA,
          FlChartModel.STYLE_STACKEDPERCENTBARS,
          FlChartModel.STYLE_STACKEDPERCENTHBARS,
        ])
            ? [
                for (String yColumnName in model.yColumnNames)
                  Proportion(
                    variable: yColumnName,
                    as: 'percent_$yColumnName',
                  ),
              ]
            : null,
        coord: RectCoord(color: const Color(0x00ffffff)),
        axes: [
          Defaults.horizontalAxis,
          Defaults.verticalAxis,
        ],
        selections: {
          'select': PointSelection(
            on: {
              GestureType.tap,
            },
            clear: {
              GestureType.doubleTap,
            },
            dim: Dim.x,
          ),
          'touchMove': PointSelection(
            on: kIsWeb
                ? {
                    GestureType.tap,
                    GestureType.hover,
                  }
                : {
                    GestureType.longPress,
                    GestureType.longPressMoveUpdate,
                  },
            clear: {
              GestureType.mouseExit,
            },
            dim: Dim.x,
            // toggle: true,
          ),
        },
        tooltip: TooltipGuide(
          multiTuples: false,
          followPointer: [true, true],
          align: Alignment.topLeft,
          offset: const Offset(-20, -20),
          variables: [
            "index",
            for (String yColumnLabel in model.yColumnLabels) yColumnLabel,
          ],
          layer: 100,
          selections: {
            "touchMove",
          },
        ),
        crosshair: CrosshairGuide(
          followPointer: [true, true],
          layer: 100,
          selections: {
            "touchMove",
            "select",
          },
        ),
        annotations: showLegend
            ? [
                for (int i = 0; i < model.yColumnNames.length; i++)
                  ..._buildAnnotation(
                    i,
                    model.yColumnNames.length,
                    model.yColumnLabels[i],
                  ),
              ]
            : null,
      ),
    );
  }

  /// Builds bar charts.
  Widget _buildBarChart({bool showLegend = true}) {
    return Padding(
      padding: showLegend ? const EdgeInsets.only(bottom: _legendPadding) : EdgeInsets.zero,
      child: Chart<Map<String, dynamic>>(
        data: data,
        rebuild: true,
        variables: {
          "group": Variable(
            accessor: (e) => e["group"] as String,
          ),
          "index": Variable(
            // toString() is necessary, don't ask me why.
            accessor: (e) => e["index"].toString(),
          ),
          "value": Variable(
            accessor: (e) => e["value"] as num,
            scale: model.isStyle(FlChartModel.STYLE_STACKEDBARS) || model.isStyle(FlChartModel.STYLE_STACKEDHBARS)
                ? LinearScale(
                    max: highestStackedValue + 1,
                  )
                : LinearScale(
                    max: highestValue + 1,
                  ),
          ),
        },
        marks: [
          if (model.isStyle(FlChartModel.STYLE_BARS) || model.isStyle(FlChartModel.STYLE_HBARS))
            IntervalMark(
              position: Varset("index") * Varset("value") / Varset("group"),
              color: ColorEncode(variable: "group", values: FlChartWidget.colors),
              label: LabelEncode(encoder: (tuple) => Label(tuple["value"].toString())),
              size: SizeEncode(value: 10),
              modifiers: [DodgeModifier(ratio: 0.29)],
              // selectionStream: selectionStream,
            ),
          if (model.isStyle(FlChartModel.STYLE_STACKEDBARS) || model.isStyle(FlChartModel.STYLE_STACKEDHBARS))
            IntervalMark(
              position: Varset("index") * Varset("value") / Varset("group"),
              color: ColorEncode(variable: "group", values: FlChartWidget.colors),
              label: LabelEncode(encoder: (tuple) => Label(tuple["value"].toString())),
              modifiers: [StackModifier()],
              // selectionStream: selectionStream,
            ),
          if (model.isStyle(FlChartModel.STYLE_STACKEDPERCENTBARS) ||
              model.isStyle(FlChartModel.STYLE_STACKEDPERCENTHBARS))
            // TODO
            IntervalMark(
              position: Varset("index") * Varset('percent') / Varset("group"),
              color: ColorEncode(variable: "group", values: FlChartWidget.colors),
              label: LabelEncode(encoder: (tuple) => Label(tuple["value"].toString())),
              modifiers: [StackModifier()],
              // selectionStream: selectionStream,
            ),
          if (model.isStyle(FlChartModel.STYLE_OVERLAPPEDBARS) || model.isStyle(FlChartModel.STYLE_OVERLAPPEDHBARS))
            IntervalMark(
              position: Varset("index") * Varset("value") / Varset("group"),
              color: ColorEncode(variable: "group", values: FlChartWidget.colors),
              label: LabelEncode(encoder: (tuple) => Label(tuple["value"].toString())),
              // selectionStream: selectionStream,
            ),
        ],
        transforms: model.isStyle(FlChartModel.STYLE_STACKEDPERCENTBARS) ||
                model.isStyle(FlChartModel.STYLE_STACKEDPERCENTHBARS)
            ? [
                Proportion(
                  variable: "value",
                  as: 'percent',
                ),
              ]
            : null,
        // coord: RectCoord(transposed: model.isHorizontalBarStyle()),
        // axes: model.isHorizontalBarStyle()
        //     ? [
        //         Defaults.verticalAxis,
        //         Defaults.horizontalAxis,
        //       ]
        //     : [
        //         Defaults.horizontalAxis,
        //         Defaults.verticalAxis,
        //       ],
        // Selection has same problem as single mark chart. Solution -> ? as multi marks break StackModifier.
        annotations: showLegend
            ? [
                for (int i = 0; i < model.yColumnNames.length; i++)
                  ..._buildAnnotation(
                    i,
                    model.yColumnNames.length,
                    model.yColumnLabels[i],
                  ),
              ]
            : null,
      ),
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

  List<Mark<Shape>> _createMark(int chartStyle, int layer, String yColumnName) {
    switch (chartStyle) {
      case FlChartModel.STYLE_STEPLINES:
      // StepLines not possible: https://github.com/entronad/graphic/issues/182
      case FlChartModel.STYLE_LINES:
        return _createLineMark(layer, yColumnName);
      case FlChartModel.STYLE_OVERLAPPEDBARS:
        return _createOverlappedBarMark(layer, yColumnName);
      case FlChartModel.STYLE_STACKEDPERCENTAREA:
        // TODO implement correctly
        return _createStackedPercentAreaMark(layer, yColumnName);
      case FlChartModel.STYLE_STACKEDPERCENTBARS:
        // TODO implement correctly
        return _createStackedPercentBarMark(layer, yColumnName);
      case FlChartModel.STYLE_STACKEDPERCENTHBARS:
        // TODO implement correctly
        return _createStackedPercentHBarMark(layer, yColumnName);
      case FlChartModel.STYLE_AREA:
      default:
        return _createAreaMark(layer, yColumnName);
    }
  }

  List<Mark<Shape>> _createLineMark(int layer, String yColumnName) {
    return [
      LineMark(
        position: Varset("index") * Varset(yColumnName),
        shape: ShapeEncode(value: BasicLineShape(dash: [5, 2])),
        color: ColorEncode(
          variable: yColumnName,
          values: FlChartWidget.colors,
        ),
        layer: layer,
        selectionStream: selectionStream,
      ),
      PointMark(
        position: Varset("index") * Varset(yColumnName),
        size: SizeEncode(value: 12),
        color: ColorEncode(
          encoder: (_) {
            return ContinuousColorConv(
              FlChartWidget.colors,
              _defaultStops(FlChartWidget.colors.length),
            ).convert(model.yColumnNames.indexOf(yColumnName) / FlChartWidget.colors.length);
          },
        ),
      ),
    ];
  }

  List<Mark<Shape>> _createAreaMark(int layer, String yColumnName) {
    return [
      AreaMark(
        position: Varset("index") * Varset(yColumnName),
        color: ColorEncode(
          variable: yColumnName,
          values: FlChartWidget.colors,
        ),
        layer: layer,
        selectionStream: selectionStream,
      ),
    ];
  }

  List<Mark<Shape>> _createOverlappedBarMark(int layer, String yColumnName) {
    return [
      IntervalMark(
        position: Varset("index") * Varset(yColumnName),
        label: LabelEncode(encoder: (tuple) => Label(tuple[yColumnName].toString())),
        color: ColorEncode(
          variable: yColumnName,
          values: FlChartWidget.colors,
        ),
        layer: layer,
        selectionStream: selectionStream,
      )
    ];
  }

  /// Currently unused.
  List<Mark<Shape>> _createStackedPercentAreaMark(int layer, String yColumnName) {
    return [
      AreaMark(
        position: Varset("index") * Varset(yColumnName),
        color: ColorEncode(
          variable: yColumnName,
          values: FlChartWidget.colors,
        ),
        layer: layer,
        modifiers: [StackModifier()],
        selectionStream: selectionStream,
      ),
    ];
  }

  /// Currently unused.
  List<Mark<Shape>> _createStackedPercentBarMark(int layer, String yColumnName) {
    return [
      IntervalMark(
        position: Varset("index") * Varset('percent_$yColumnName'),
        label: LabelEncode(encoder: (tuple) => Label(tuple[yColumnName].toString())),
        color: ColorEncode(
          variable: yColumnName,
          values: FlChartWidget.colors,
        ),
        modifiers: [StackModifier()],
        selectionStream: selectionStream,
      )
    ];
  }

  /// Currently unused.
  List<Mark<Shape>> _createStackedPercentHBarMark(int layer, String yColumnName) {
    return [
      IntervalMark(
        position: Varset("index") * Varset('percent_$yColumnName'),
        label: LabelEncode(encoder: (tuple) => Label(tuple[yColumnName].toString())),
        color: ColorEncode(
          variable: yColumnName,
          values: FlChartWidget.colors,
        ),
        modifiers: [StackModifier()],
        selectionStream: selectionStream,
      )
    ];
  }

  /// Gets default equidistant stops.
  ///
  /// Copied from `graphic-2.2.0/lib/src/encode/channel.dart`.
  List<double> _defaultStops(int length) {
    final step = 1 / (length - 1);
    final rst = <double>[0];
    for (var i = 1; i < length - 1; i++) {
      rst.add(step * i);
    }
    rst.add(1);
    return rst;
  }

  /// Currently unused as this orders the layers randomly and only shows the tooltip for the top-most mark.
  Chart<Map<String, dynamic>> _buildSingleMarkLineChart() {
    return Chart<Map<String, dynamic>>(
      data: data,
      variables: {
        "index": Variable(
          accessor: (e) => e["index"] as num,
        ),
        "value": Variable(
          accessor: (e) => e["value"] as num,
        ),
        "group": Variable(
          accessor: (e) => e["group"] as String,
        ),
      },
      marks: [
        LineMark(
          position: Varset("index") * Varset("value") / Varset("group"),
          shape: ShapeEncode(value: BasicLineShape(dash: [5, 2])),
          // size: SizeEncode(value: 0.9),
          selected: {
            'touchMove': {1, 2, 3},
          },
          color: colorEncode(),
          layer: 0,
        ),
        AreaMark(
          position: Varset("index") * Varset("value") / Varset("group"),
          color: colorEncode(),
          layer: 0,
        ),
      ],
      coord: RectCoord(color: const Color(0x00ffffff)),
      axes: [
        Defaults.horizontalAxis,
        Defaults.verticalAxis,
      ],
      selections: {
        'touchMove': PointSelection(
          // variable: "Category",
          on: {
            GestureType.scaleUpdate,
            GestureType.tapDown,
            GestureType.longPressMoveUpdate,
          },
          dim: Dim.x,
        )
      },
      tooltip: TooltipGuide(
        followPointer: [false, true],
        align: Alignment.topLeft,
        offset: const Offset(-20, -20),
        variables: [
          "index",
          "value",
          "group",
        ],
      ),
      crosshair: CrosshairGuide(followPointer: [false, true]),
    );
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

  Widget _buildLineChart(BuildContext context) {
    return Chart<Map<String, dynamic>>(
      data: data,
      variables: variables(),
      marks: [
        LineMark(
          position: position(),
          shape: ShapeEncode(value: BasicLineShape()),
          color: colorEncode(),
        ),
        PointMark(
          position: position(),
          color: colorEncode(),
        )
      ],
      coord: coord(context),
      axes: [
        Defaults.horizontalAxis,
        Defaults.verticalAxis,
      ],
      selections: {
        'select': PointSelection(
          nearest: false,
          on: {
            GestureType.tap,
          },
          dim: Dim.x,
        )
      },
    );
  }

  Widget _buildAreaChart(BuildContext context) {
    AreaMark areaMark = AreaMark(
      position: position(),
      color: colorEncode(),
    );

    if (model.isStackedChart()) {
      areaMark.modifiers = [StackModifier()];
    }

    return Chart<Map<String, dynamic>>(
      data: data,
      rebuild: true,
      variables: variables(),
      marks: [areaMark],
      transforms: transform(),
      coord: coord(context),
      axes: [
        Defaults.horizontalAxis,
        Defaults.verticalAxis,
      ],
      selections: {
        'select': PointSelection(
          nearest: false,
          on: {
            GestureType.tap,
          },
          dim: Dim.x,
        )
      },
    );
  }

  /// Default variables for the charts.
  Map<String, Variable<Map<String, dynamic>, dynamic>> variables() {
    // indexAreCategory => must replace whole "accessor" function,
    // as the return type gets checked via type check and not actual value.
    return {
      "index": Variable(
        accessor: indexAreCategory ? ((e) => e["index"] as String) : ((e) => e["index"] as num),
      ),
      "value": Variable(
        accessor: (e) => e["value"] as num,
        scale: LinearScale(min: 0, max: maxValue()),
      ),
      "group": Variable(
        accessor: (e) => e["group"] as String,
      ),
    };
  }

  num maxValue() => (model.isStackedChart() ? highestStackedValue : highestValue) * 1.05;

  Varset position() {
    if (model.isPercentChart()) {
      return Varset("index") * Varset("percent") / Varset("group");
    }

    return Varset("index") * Varset("value") / Varset("group");
  }

  ColorEncode colorEncode() {
    return ColorEncode(
      variable: "group",
      values: colors,
    );
  }

  Coord coord(BuildContext context) {
    return RectCoord(color: Theme.of(context).colorScheme.background);
  }

  List<VariableTransform>? transform() {
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
}
