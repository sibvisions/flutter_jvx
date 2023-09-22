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
  final num maxYvalue;
  final num maxCombinedYvalue;
  final StreamController<Selected?>? selectionStream;
  final bool showLegend;

  static const colors = [
    Color(0xFFFF6384),
    Color(0x9936A2EB),
    Color(0x99FFCE56),
    Color(0x994BC0C0),
    Color(0x999966FF),
    Color(0x99FF9F40),
  ];

  const FlChartWidget({
    super.key,
    required super.model,
    required this.maxYvalue,
    required this.maxCombinedYvalue,
    required this.data,
    this.selectionStream,
    this.showLegend = true,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(child: Text(FlutterUI.translate("No data to display")));
    }

    if (model.matchesStyles(const [
      FlChartModel.STYLE_STACKEDAREA,
      FlChartModel.STYLE_STACKEDPERCENTAREA,
    ])) {
      return _buildAreaChart(showLegend: showLegend);
    }

    if (model.matchesStyles(const [
      // Vertical
      FlChartModel.STYLE_BARS,
      FlChartModel.STYLE_STACKEDBARS,
      FlChartModel.STYLE_STACKEDPERCENTBARS,
      // FlChartModel.STYLE_OVERLAPPEDBARS,
      // Horizontal
      FlChartModel.STYLE_HBARS,
      FlChartModel.STYLE_STACKEDHBARS,
      FlChartModel.STYLE_STACKEDPERCENTHBARS,
      FlChartModel.STYLE_OVERLAPPEDHBARS,
    ])) {
      return _buildBarChart(showLegend: showLegend);
    }

    if (model.isStyle(FlChartModel.STYLE_PIE) || model.isStyle(FlChartModel.STYLE_RING)) {
      return _buildPieChart(showLegend: showLegend);
    }

    // Colors are mixed!
    return _buildGenericChart(showLegend: false);
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
          'X': Variable(
            accessor: (e) => e['X'] as num,
          ),
          for (String yColumnName in model.yColumnNames)
            yColumnName: Variable(
              accessor: (e) => e[yColumnName] as num,
              scale: LinearScale(max: model.isStyle(FlChartModel.STYLE_OVERLAPPEDBARS) ? maxYvalue + 1 : maxYvalue),
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
            'X',
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

  /// Builds non-generic (e.g. stacked) area charts.
  Widget _buildAreaChart({bool showLegend = true}) {
    return Padding(
      padding: showLegend ? const EdgeInsets.only(bottom: _legendPadding) : EdgeInsets.zero,
      child: Chart<Map<String, dynamic>>(
        data: data,
        rebuild: true,
        variables: {
          'Category': Variable(
            accessor: (e) => e['Category'] as String,
          ),
          'X': Variable(
            // toString() is necessary, don't ask me why.
            accessor: (e) => e['X'].toString(),
          ),
          'Y': Variable(
            accessor: (e) => e['Y'] as num,
            scale: model.isStyle(FlChartModel.STYLE_STACKEDAREA)
                ? LinearScale(
                    max: maxCombinedYvalue + 1,
                  )
                : LinearScale(
                    max: maxYvalue + 1,
                  ),
          ),
        },
        marks: [
          if (!model.isStyle(FlChartModel.STYLE_STACKEDPERCENTAREA))
            AreaMark(
              position: Varset('X') * Varset('Y') / Varset('Category'),
              color: ColorEncode(variable: 'Category', values: FlChartWidget.colors),
              modifiers: [StackModifier()],
              // selectionStream: selectionStream,
            ),
          if (model.isStyle(FlChartModel.STYLE_STACKEDPERCENTAREA))
            // TODO
            AreaMark(
              position: Varset('X') * Varset('percent') / Varset('Category'),
              color: ColorEncode(variable: 'Category', values: FlChartWidget.colors),
              modifiers: [StackModifier()],
              // selectionStream: selectionStream,
            ),
        ],
        transforms: model.isStyle(FlChartModel.STYLE_STACKEDPERCENTAREA)
            ? [
                Proportion(
                  variable: 'Y',
                  as: 'percent',
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
            'X',
            'Y',
            'Category',
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
          'Category': Variable(
            accessor: (e) => e['Category'] as String,
          ),
          'X': Variable(
            // toString() is necessary, don't ask me why.
            accessor: (e) => e['X'].toString(),
          ),
          'Y': Variable(
            accessor: (e) => e['Y'] as num,
            scale: model.isStyle(FlChartModel.STYLE_STACKEDBARS) || model.isStyle(FlChartModel.STYLE_STACKEDHBARS)
                ? LinearScale(
                    max: maxCombinedYvalue + 1,
                  )
                : LinearScale(
                    max: maxYvalue + 1,
                  ),
          ),
        },
        marks: [
          if (model.isStyle(FlChartModel.STYLE_BARS) || model.isStyle(FlChartModel.STYLE_HBARS))
            IntervalMark(
              position: Varset('X') * Varset('Y') / Varset('Category'),
              color: ColorEncode(variable: 'Category', values: FlChartWidget.colors),
              label: LabelEncode(encoder: (tuple) => Label(tuple['Y'].toString())),
              size: SizeEncode(value: 10),
              modifiers: [DodgeModifier(ratio: 0.29)],
              // selectionStream: selectionStream,
            ),
          if (model.isStyle(FlChartModel.STYLE_STACKEDBARS) || model.isStyle(FlChartModel.STYLE_STACKEDHBARS))
            IntervalMark(
              position: Varset('X') * Varset('Y') / Varset('Category'),
              color: ColorEncode(variable: 'Category', values: FlChartWidget.colors),
              label: LabelEncode(encoder: (tuple) => Label(tuple['Y'].toString())),
              modifiers: [StackModifier()],
              // selectionStream: selectionStream,
            ),
          if (model.isStyle(FlChartModel.STYLE_STACKEDPERCENTBARS) ||
              model.isStyle(FlChartModel.STYLE_STACKEDPERCENTHBARS))
            // TODO
            IntervalMark(
              position: Varset('X') * Varset('percent') / Varset('Category'),
              color: ColorEncode(variable: 'Category', values: FlChartWidget.colors),
              label: LabelEncode(encoder: (tuple) => Label(tuple['Y'].toString())),
              modifiers: [StackModifier()],
              // selectionStream: selectionStream,
            ),
          if (model.isStyle(FlChartModel.STYLE_OVERLAPPEDBARS) || model.isStyle(FlChartModel.STYLE_OVERLAPPEDHBARS))
            IntervalMark(
              position: Varset('X') * Varset('Y') / Varset('Category'),
              color: ColorEncode(variable: 'Category', values: FlChartWidget.colors),
              label: LabelEncode(encoder: (tuple) => Label(tuple['Y'].toString())),
              // selectionStream: selectionStream,
            ),
        ],
        transforms: model.isStyle(FlChartModel.STYLE_STACKEDPERCENTBARS) ||
                model.isStyle(FlChartModel.STYLE_STACKEDPERCENTHBARS)
            ? [
                Proportion(
                  variable: 'Y',
                  as: 'percent',
                ),
              ]
            : null,
        coord: RectCoord(transposed: model.isHorizontalBarStyle()),
        axes: model.isHorizontalBarStyle()
            ? [
                Defaults.verticalAxis,
                Defaults.horizontalAxis,
              ]
            : [
                Defaults.horizontalAxis,
                Defaults.verticalAxis,
              ],
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
    return Padding(
      padding: showLegend ? const EdgeInsets.only(bottom: _legendPadding) : EdgeInsets.zero,
      child: Chart<Map<String, dynamic>>(
        data: data,
        rebuild: true,
        variables: {
          'X': Variable(
            accessor: (e) => e['X'].toString(),
          ),
          'Y': Variable(
            accessor: (e) => e['Y'] as num,
          ),
        },
        transforms: [
          Proportion(
            variable: 'Y',
            as: 'percent',
          ),
        ],
        marks: [
          IntervalMark(
            position: Varset('percent') / Varset('X'),
            label: LabelEncode(
              encoder: (tuple) => Label(
                "${tuple['X']}: ${(tuple['percent'] * 100).round()}%",
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
            color: ColorEncode(variable: 'X', values: FlChartWidget.colors),
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
                      data[i]['X'],
                    ),
              ]
            : null,
      ),
    );
  }

  List<Mark<Shape>> _createMark(int chartStyle, int layer, String yColumnName) {
    switch (chartStyle) {
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
        position: Varset('X') * Varset(yColumnName),
        shape: ShapeEncode(value: BasicLineShape(dash: [5, 2])),
        color: ColorEncode(
          variable: yColumnName,
          values: FlChartWidget.colors,
        ),
        layer: layer,
        selectionStream: selectionStream,
      ),
      PointMark(
        position: Varset('X') * Varset(yColumnName),
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
        position: Varset('X') * Varset(yColumnName),
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
        position: Varset('X') * Varset(yColumnName),
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
        position: Varset('X') * Varset(yColumnName),
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
        position: Varset('X') * Varset('percent_$yColumnName'),
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
        position: Varset('X') * Varset('percent_$yColumnName'),
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
        'X': Variable(
          accessor: (e) => e['X'] as num,
        ),
        'Y': Variable(
          accessor: (e) => e['Y'] as num,
        ),
        'Category': Variable(
          accessor: (e) => e['Category'] as String,
        ),
      },
      marks: [
        LineMark(
          position: Varset('X') * Varset('Y') / Varset('Category'),
          shape: ShapeEncode(value: BasicLineShape(dash: [5, 2])),
          // size: SizeEncode(value: 0.9),
          selected: {
            'touchMove': {1, 2, 3},
          },
          color: ColorEncode(
            variable: 'Category',
            values: colors,
          ),
          layer: 0,
        ),
        AreaMark(
          position: Varset('X') * Varset('Y') / Varset('Category'),
          color: ColorEncode(
            variable: 'Category',
            values: colors,
          ),
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
          'X',
          'Y',
          'Category',
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
}
