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
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:graphic/graphic.dart' show Selected;

import '../../model/command/api/mouse_clicked_command.dart';
import '../../model/command/api/mouse_pressed_command.dart';
import '../../model/command/api/mouse_released_command.dart';
import '../../model/command/api/select_record_command.dart';
import '../../model/command/base_command.dart';
import '../../model/command/ui/set_focus_command.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/data/data_book.dart';
import '../../model/data/subscriptions/data_chunk.dart';
import '../../model/data/subscriptions/data_record.dart';
import '../../model/data/subscriptions/data_subscription.dart';
import '../../model/request/filter.dart';
import '../../service/ui/i_ui_service.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';
import 'fl_chart_widget.dart';

class FlChartWrapper extends BaseCompWrapperWidget<FlChartModel> {
  const FlChartWrapper({super.key, required super.model});

  @override
  BaseCompWrapperState<FlComponentModel> createState() => _FlChartWrapperState();
}

class _FlChartWrapperState extends BaseCompWrapperState<FlChartModel> {
  DataChunk? chunkData;
  DalMetaData? metaData;

  (List<Map<String, dynamic>>, num, num)? computedChartData;
  late final StreamController<Selected?> selectionStream;

  int? lastIndex;

  @override
  void initState() {
    super.initState();

    selectionStream = StreamController.broadcast();
    selectionStream.stream.listen((event) {
      if (event == null || event.containsKey("select")) {
        onIndexSelected(event?['select']?.firstOrNull);
      }
    });

    subscribe();
  }

  @override
  void modelUpdated() {
    super.modelUpdated();
    unsubscribe();
    subscribe();
  }

  @override
  void dispose() {
    selectionStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget widget;
    if (computedChartData == null) {
      widget = Container();
    } else {
      widget = FlChartWidget(
        model: model,
        data: computedChartData!.$1,
        maxYvalue: computedChartData!.$2,
        maxCombinedYvalue: computedChartData!.$3,
        selectionStream: selectionStream,
      );
    }
    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return wrapWidget(child: widget);
  }

  void subscribe() {
    if (model.yColumnNames.isNotEmpty && model.xColumnName.isNotEmpty) {
      IUiService().registerDataSubscription(
        pDataSubscription: DataSubscription(
          subbedObj: this,
          from: 0,
          dataProvider: model.dataProvider,
          onDataChunk: receiveChartData,
          onSelectedRecord: receiveSelectedChartData,
          onMetaData: receiveMetaData,
        ),
      );
    }
  }

  void unsubscribe() {
    IUiService().disposeDataSubscription(pSubscriber: this, pDataProvider: model.dataProvider);
  }

  void receiveChartData(DataChunk pChunkData) {
    chunkData = pChunkData;
    computedChartData = computeData(pChunkData);
    setState(() {});
  }

  void receiveSelectedChartData(DataRecord? dataRecord) {
    computedChartData = computeData(chunkData, dataRecord: dataRecord);
    setState(() {});
  }

  void receiveMetaData(DalMetaData pMetaData) {
    metaData = pMetaData;
    setState(() {});
  }

  (List<Map<String, dynamic>>, num, num) computeData(DataChunk? pChunkData, {DataRecord? dataRecord}) {
    if (model.matchesStyles(const [
      // Area
      FlChartModel.STYLE_STACKEDAREA,
      FlChartModel.STYLE_STACKEDPERCENTAREA,
      // Bar
      FlChartModel.STYLE_RING,
      FlChartModel.STYLE_BARS,
      FlChartModel.STYLE_STACKEDBARS,
      FlChartModel.STYLE_STACKEDPERCENTBARS,
      // FlChartModel.STYLE_OVERLAPPEDBARS,
      // HBar
      FlChartModel.STYLE_HBARS,
      FlChartModel.STYLE_STACKEDHBARS,
      FlChartModel.STYLE_STACKEDPERCENTHBARS,
      FlChartModel.STYLE_OVERLAPPEDHBARS,
      // Pie
      FlChartModel.STYLE_PIE,
      FlChartModel.STYLE_RING,
    ])) {
      return computeChartData(pChunkData, dataRecord: dataRecord);
    } else {
      return computeGenericChartData(pChunkData, dataRecord: dataRecord);
    }
  }

  /// Transforms chart data into the appropriate format.
  ///
  /// Used for [FlChartModel.STYLE_PIE], [FlChartModel.STYLE_RING] and stacked charts.
  ///
  /// Single Y-Column:
  /// ```dart
  /// [
  ///   {Index: 0, X: A, Y: 9},
  ///   {Index: 1, X: B, Y: 27},
  ///   {Index: 2, X: C, Y: 16},
  ///   {Index: 3, X: D, Y: 11},
  ///   {Index: 4, X: E, Y: 6},
  /// ]
  /// ```
  (List<Map<String, dynamic>>, num, num) computeChartData(DataChunk? dataChunk, {DataRecord? dataRecord}) {
    List<Map<String, dynamic>> chartData = [];
    num maxValue = 1;
    num maxCombinedValue = 1;

    if (dataChunk != null) {
      var entries = dataChunk.data.entries.sorted((a, b) => a.key.compareTo(b.key));
      int xColumnIndex = dataChunk.getColumnIndex(model.xColumnName);

      if (model.isPieChart()) {
        if (model.yColumnNames.length == 1) {
          String yColumn = model.yColumnNames.first;
          int yColumnIndex = dataChunk.getColumnIndex(yColumn);

          // Group by `xColumnIndex`: {'A': [[1, 1, 2, 3, 'A'], ...], 'B': [...], ...}
          Map<dynamic, List<List<dynamic>>> typeMap =
              entries.map((e) => e.value).groupListsBy((element) => element[xColumnIndex]);

          // Then sum all `yColumn` values: {A: 9, B: 27, C: 16, D: 11, E: 6}
          Map<dynamic, dynamic> groupedValues = typeMap.map((key, value) =>
              MapEntry(key, value.map((e) => e[yColumnIndex]).reduce((value, element) => value + element)));

          var groupedEntries = groupedValues.entries.toList();
          for (int i = 0; i < groupedEntries.length; i++) {
            var entry = groupedEntries[i];
            chartData.add(
              {
                "Index": i,
                "X": entry.key,
                "Y": entry.value,
              },
            );
            maxValue = max(maxValue, entry.value);
          }
          maxCombinedValue = maxValue;
        } else {
          // // {'Category': 'Y1', X: 'A', Y: 63}
          //
          // // Group by `xColumnIndex`: {'A': [[1, 1, 2, 3, 'A'], ...], 'B': [...], ...}
          // Map<dynamic, List<List<dynamic>>> typeMap =
          //     entries.map((e) => e.value).groupListsBy((element) => element[xColumnIndex]);
          //
          // // Then sum all `yColumn` values: {A: {Y1: 88, Y2: 24, Y3: 45}, B: {Y1: 23, ...}, ...}
          // Map<dynamic, Map<String, dynamic>> groupedValues = typeMap.map(
          //   (key, value) => MapEntry(
          //     key,
          //     value.map((e) {
          //       Map<String, dynamic> dataEntry = {};
          //       for (String yColumn in model.yColumnNames) {
          //         int yColumnIndex = dataChunk.getColumnIndex(yColumn);
          //         dataEntry[yColumn] = e[yColumnIndex] + (dataEntry[yColumn] ?? 0);
          //       }
          //       return dataEntry;
          //     }).reduce((value, e) {
          //       for (String key in e.keys) {
          //         value[key] += e[key];
          //       }
          //       return value;
          //     }),
          //   ),
          // );
          //
          // print(groupedValues);

          // // {Category: Y1, X: A, Y: 9}
          // var groupedEntries = groupedValues.entries.toList();
          // for (int i = 0; i < groupedEntries.length; i++) {
          //   var entry = groupedEntries[i];
          //   for (String key in entry.value.keys) {
          //     chartData.add(
          //       {
          //         "Category": key,
          //         "X": entry.key,
          //         "Y": entry.value[key],
          //       },
          //     );
          //     // maxValue = max(maxValue, entry.value as num);
          //   }
          // }
          // maxCombinedValue = maxValue;

          // {A: {Y1: 88, Y2: 24, Y3: 45}, B: {Y1: 23, ...}, ...}
          // {X: 'A', Y1: '63', Y2: '15', Y3: '79'}
          // var groupedEntries = groupedValues.entries.toList();
          // for (int i = 0; i < groupedEntries.length; i++) {
          //   var entry = groupedEntries[i];
          //   chartData.add(
          //     {
          //       "X": entry.key,
          //       ...entry.value,
          //     },
          //   );
          //   // maxValue = max(maxValue, entry.value);
          // }
          // maxCombinedValue = maxValue;

          // This pie chart needs the currently selected row.
          if (dataRecord != null) {
            // {'X': 'Y1', Y: 63}
            for (String yColumn in model.yColumnNames) {
              int yColumnIndex = dataChunk.getColumnIndex(yColumn);
              num y = extractValue(dataRecord.values[yColumnIndex]);
              maxValue = max(maxValue, y);

              chartData.add({
                'X': yColumn,
                'Y': y,
              });
            }
            maxCombinedValue = maxValue;
          }
        }
      } else {
        // TODO fix category check
        // if (model.yColumnNames.isNotEmpty &&
        //     entries.isNotEmpty &&
        //     entries[0].value[dataChunk.getColumnIndex(model.yColumnNames[0])] is String) {
        //   // Category Charts
        //   for (var entry in entries) {
        //     num combinedYvalue = 0;
        //     for (String yColumn in model.yColumnNames) {
        //       int yColumnIndex = dataChunk.getColumnIndex(yColumn);
        //
        //       dynamic x = extractValue(entry.value[xColumnIndex]);
        //       num y = extractValue(entry.value[yColumnIndex]);
        //       chartData.add(
        //         {
        //           "X": x,
        //           "Y": y,
        //           "Category": yColumn,
        //         },
        //       );
        //
        //       combinedYvalue = combinedYvalue + y;
        //       maxValue = max(maxValue, y);
        //     }
        //
        //     maxCombinedValue = max(maxCombinedValue, combinedYvalue);
        //   }
        // } else {
        // XY Charts
        for (var entry in entries) {
          num combinedYvalue = 0;
          for (String yColumn in model.yColumnNames) {
            int yColumnIndex = dataChunk.getColumnIndex(yColumn);

            dynamic x = extractValue(entry.value[xColumnIndex]);
            num y = extractValue(entry.value[yColumnIndex]);
            chartData.add(
              {
                "X": x,
                "Y": y,
                "Category": yColumn,
              },
            );

            combinedYvalue = combinedYvalue + y;
            maxValue = max(maxValue, y);
          }

          maxCombinedValue = max(maxCombinedValue, combinedYvalue);
        }
        // }
      }
    }

    return (chartData, maxValue, maxCombinedValue);
  }

  /// Transforms the chart data into the appropriate format.
  ///
  /// e.g. {A: 9, B: 27, C: 16, D: 11, E: 6}
  (List<Map<String, dynamic>>, num, num) computeGenericChartData(DataChunk? dataChunk, {DataRecord? dataRecord}) {
    List<Map<String, dynamic>> chartData = [];
    num maxValue = 1;
    num maxCombinedValue = 1;

    if (dataChunk != null) {
      var entries = dataChunk.data.entries.sorted((a, b) => a.key.compareTo(b.key));

      int xColumnIndex = dataChunk.getColumnIndex(model.xColumnName);
      for (var entry in entries) {
        num combinedYvalue = 1;
        var chartEntry = {
          "X": extractValue(entry.value[xColumnIndex], fallback: entry.key),
        };

        for (String yColumn in model.yColumnNames) {
          num y = extractValue(entry.value[dataChunk.getColumnIndex(yColumn)]);
          chartEntry[yColumn] = y;

          combinedYvalue = combinedYvalue + y;
          maxValue = max(maxValue, y);
        }

        chartData.add(chartEntry);

        maxCombinedValue = max(maxCombinedValue, combinedYvalue);
      }
    }

    return (chartData, maxValue, maxCombinedValue);
  }

  dynamic extractValue(dynamic e, {dynamic fallback}) {
    return e is num ? e : double.tryParse(e) ?? fallback ?? e.toString();
  }

  void onIndexSelected(int? pIndex) {
    if (chunkData == null || metaData == null) {
      return;
    }

    print("Selected Index: $pIndex");

    if (lastIndex == pIndex) {
      return;
    }
    lastIndex = pIndex;

    IUiService()
        .saveAllEditors(
          pId: model.id,
          pFunction: () {
            List<BaseCommand> commands = [];

            var oldFocus = IUiService().getFocus();
            commands.add(SetFocusCommand(componentId: model.id, focus: true, reason: "Selected record in chart"));

            if (pIndex != null) {
              commands.add(
                SelectRecordCommand.select(
                  reason: "Selected record in chart",
                  dataProvider: model.dataProvider,
                  filter: Filter(
                    columnNames: metaData!.primaryKeyColumns,
                    values: metaData!.primaryKeyColumns
                        .map((columnName) => chunkData!.data[pIndex]![
                            chunkData!.columnDefinitions.indexWhere((colDef) => colDef.name == columnName)])
                        .toList(),
                  ),
                  rowNumber: pIndex,
                ),
              );
            } else {
              commands.add(
                SelectRecordCommand.deselect(
                  reason: "Deselected record in chart",
                  dataProvider: model.dataProvider,
                ),
              );
            }

            commands.addAll([
              MousePressedCommand(reason: "Selected record in chart", componentName: model.name),
              MouseReleasedCommand(reason: "Selected record in chart", componentName: model.name),
              MouseClickedCommand(reason: "Selected record in chart", componentName: model.name)
            ]);

            if (oldFocus != null) {
              commands.add(SetFocusCommand(componentId: oldFocus.id, focus: true, reason: "Selected record in chart"));
            } else {
              commands.add(SetFocusCommand(componentId: model.id, focus: false, reason: "Selected record in chart"));
            }

            return commands;
          },
          pReason: "Selected record in chart",
        )
        .catchError(IUiService().handleAsyncError);
  }
}
