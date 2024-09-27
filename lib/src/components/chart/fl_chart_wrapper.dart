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
import 'dart:collection';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:graphic/graphic.dart' show Selected;

import '../../../flutter_jvx.dart';
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
import '../../service/api/shared/api_object_property.dart';
import '../../service/command/i_command_service.dart';
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
  DataChunk? dataChunk;
  DataRecord? dataRecord;
  DalMetaData? metaData;

  bool isCategoryChart = false;
  List<Map<String, dynamic>> chartData = [];
  num highestValue = 1;
  num highestStackedValue = 1;

  late final StreamController<Selected?> selectionStream;

  int? lastIndex;

  String? lastColumn;

  @override
  void initState() {
    super.initState();

    selectionStream = StreamController.broadcast();

    selectionStream.stream.listen(handleSelection);

    subscribe();
  }

  @override
  void modelUpdated() {
    super.modelUpdated();

    if (model.lastChangedProperties.contains(ApiObjectProperty.dataProvider)) {
      unsubscribe();
      subscribe();
    }
  }

  @override
  void dispose() {
    selectionStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    if (model.yColumnNames.isEmpty && model.xColumnName.isEmpty) {
      return wrapWidget(child: Center(child: Text("Invalid Chart: ${model.name}")));
    }

    if (dataChunk == null || metaData == null) {
      return wrapWidget(child: const Center(child: CircularProgressIndicator()));
    }

    return wrapWidget(
      child: FlChartWidget(
        model: model,
        data: chartData,
        highestValue: highestValue,
        highestStackedValue: highestStackedValue,
        selectionStream: selectionStream,
      ),
    );
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
    dataChunk = pChunkData;

    computeData();
    setState(() {});
  }

  void receiveSelectedChartData(DataRecord? pDataRecord) {
    dataRecord = pDataRecord;

    if (model.isPieChart() && model.yColumnLabels.length > 1) {
      computeData();
      setState(() {});
    }
  }

  void receiveMetaData(DalMetaData pMetaData) {
    metaData = pMetaData;

    computeData();
    setState(() {});
  }

  void computeData() {
    final dataChunk = this.dataChunk;
    final dataRecord = this.dataRecord;

    if (metaData == null || dataChunk == null) {
      return;
    }

    List<int> sortedRowIndexKeys = dataChunk.data.keys.sorted((a, b) => a.compareTo(b));
    List<List<dynamic>> sortedDataRows = sortedRowIndexKeys.map((key) => dataChunk.data[key]!).toList();
    chartData = [];
    highestValue = 1;
    highestStackedValue = 1;

    int indexColumnIndex = dataChunk.columnDefinitionIndex(model.xColumnName);

    if (model.isPieChart()) {
      if (model.yColumnLabels.length == 1) {
        LinkedHashMap<String, num> mapOfIndexValues = LinkedHashMap();
        int valueColumnIndex = dataChunk.columnDefinitionIndex(model.yColumnNames.first);

        for (var dataRow in sortedDataRows) {
          String index = dataRow[indexColumnIndex].toString();
          num value = parseToNum(dataRow[valueColumnIndex]);

          mapOfIndexValues[index] = (mapOfIndexValues[index] ?? 0.0) + value;
        }

        highestStackedValue = 0.0;
        for (MapEntry entry in mapOfIndexValues.entries) {
          chartData.add(
            {
              "index": entry.key,
              "value": entry.value,
            },
          );

          highestStackedValue += entry.value;
          highestValue = max(highestValue, entry.value);
        }
      } else if (dataRecord != null && dataChunk.data.containsKey(dataRecord.index)) {
        var dataRow = dataChunk.data[dataRecord.index]!;

        for (String valueColumnName in model.yColumnNames) {
          num value = parseToNum(dataRow[dataChunk.columnDefinitionIndex(valueColumnName)]);

          chartData.add(
            {
              "index": valueColumnName,
              "value": value,
            },
          );

          highestStackedValue += value;
          highestValue = max(highestValue, value);
        }
      }
    } else {
      // Category charts have a string column as their xColumn (index column).
      // The index for the chart data is still the value inside the column but the value can
      // occur multiple times. The values of the yColumns (value columns) must the added together so every
      // value inside the xColumn used as an index is distinct in the resulting map.
      // E.g.
      // Line1  Line2  Type
      //   1      1     A
      //   2      1     A
      //   2      2     B
      //   3      2     B
      // Line1 has the coordinates of A=3, B=5
      // Line2 has the coordinates of A=2, B=4
      if (model.isCategoryChart(dataChunk.columnDefinitions[indexColumnIndex].dataTypeIdentifier)) {
        LinkedHashMap<String, LinkedHashMap<String, num>> mapOfIndexRows = LinkedHashMap();

        for (var dataRow in sortedDataRows) {
          String index = dataRow[indexColumnIndex];

          for (String groupName in model.yColumnNames) {
            num value = parseToNum(dataRow[dataChunk.columnDefinitionIndex(groupName)]);

            Map<String, num> indexRow = mapOfIndexRows.putIfAbsent(index, () => LinkedHashMap());
            indexRow[groupName] = (indexRow[groupName] ?? 0.0) + value;
          }
        }

        for (String index in mapOfIndexRows.keys) {
          Map<String, num> indexRow = mapOfIndexRows[index]!;

          num sumOfValues = 0.0;
          for (String group in indexRow.keys) {
            num value = indexRow[group]!;

            chartData.add(
              {
                "index": index,
                "value": value,
                "group": group,
              },
            );

            sumOfValues += value;
            highestValue = max(highestValue, value);
          }

          highestStackedValue = max(highestStackedValue, sumOfValues);
        }
      } else {
        for (var dataRow in sortedDataRows) {
          num sumOfRowValues = 0;
          num index = parseToNum(dataRow[indexColumnIndex]);

          for (String groupName in model.yColumnNames) {
            num value = parseToNum(dataRow[dataChunk.columnDefinitionIndex(groupName)]);

            chartData.add(
              {
                "index": index,
                "value": value,
                "group": groupName,
              },
            );

            sumOfRowValues += value;

            highestValue = max(highestValue, value);
          }

          highestStackedValue = max(highestStackedValue, sumOfRowValues);
        }
      }
    }
  }

  num parseToNum(dynamic e, [num fallback = 0.0]) {
    if (e == null) {
      return fallback;
    }

    if (e is num) {
      return e;
    }

    return num.tryParse(e.toString()) ?? fallback;
  }

  void handleSelection(event) {
    final dataChunk = this.dataChunk;
    final metaData = this.metaData;

    if (dataChunk == null || metaData == null) {
      return;
    }

    Set<int>? indexValues = event?["index"];
    Set<int>? valueValues = event?["value"];

    // Cross the index and value indices to find the index of the chartData entry.
    int? index = indexValues?.firstWhereOrNull((element) => valueValues?.contains(element) ?? false);
    if (index != null && index < chartData.length) {
      var chartDataEntry = chartData[index];

      if (model.isPieChart()) {
        if (model.yColumnLabels.length == 1) {
          var indexValue = chartDataEntry["index"];

          // Find they key of the first row which has the "index" value of the graph inside the x column.
          var indexInDataChunk = dataChunk.data.entries.firstWhereOrNull((entry) {
            var dataRow = entry.value;
            var indexColumnIndex = dataChunk.columnDefinitionIndex(model.xColumnName);
            var indexValueInDataRow = dataRow[indexColumnIndex];

            return indexValueInDataRow?.toString() == indexValue?.toString();
          })?.key;

          onIndexSelected(indexInDataChunk, null);
        } else {
          onIndexSelected(dataRecord!.index, model.yColumnNames[index]);
        }
      } else {

        ColumnDefinition? cdef = dataChunk.columnDefinition(model.xColumnName);

        if (cdef != null && model.isCategoryChart(cdef.dataTypeIdentifier)) {
          // Category charts have a string column as their xColumn (index column).
          // The first row that satisfies the index and group condition is the correct one.
          var indexValue = chartDataEntry["index"];
          var groupValue = chartDataEntry["group"];

          // Find they key of the first row which has the "index" value of the graph inside the x column.
          var indexInDataChunk = dataChunk.data.entries.firstWhereOrNull((entry) {
            var dataRow = entry.value;
            var indexColumnIndex = dataChunk.columnDefinitionIndex(model.xColumnName);
            var indexValueInDataRow = dataRow[indexColumnIndex];

            return indexValueInDataRow?.toString() == indexValue?.toString();
          })?.key;

          onIndexSelected(indexInDataChunk, groupValue);
        } else {
          int indexOfDataChunk = (index / model.yColumnNames.length).floor();

          onIndexSelected(indexOfDataChunk, chartDataEntry["group"]);
        }
      }
    } else {
      onIndexSelected(null, null);
    }
  }

  void onIndexSelected(int? pIndex, String? pColumn) {
    if (dataChunk == null || metaData == null) {
      return;
    }

    if (lastIndex == pIndex && lastColumn == pColumn) {
      return;
    }

    lastIndex = pIndex;
    lastColumn = pColumn;

    IUiService().saveAllEditors(pId: model.id, pReason: "Chart [${model.id} record selected").then((success) {
      if (!success) {
        return false;
      }

      ICommandService().sendCommands(createSelectRecordCommands(pIndex, pColumn));
    });
  }

  List<BaseCommand> createSelectRecordCommands(int? pIndex, String? pColumn) {
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
                .map((columnName) => dataChunk!
                    .data[pIndex]![dataChunk!.columnDefinitions.indexWhere((colDef) => colDef.name == columnName)])
                .toList(),
          ),
          rowNumber: pIndex,
          selectedColumn: pColumn,
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

    if (model.eventMousePressed) {
      commands.add(MousePressedCommand(reason: "Selected record in chart", componentName: model.name));
    }

    if (model.eventMouseReleased) {
      commands.add(MouseReleasedCommand(reason: "Selected record in chart", componentName: model.name));
    }

    if (model.eventMouseClicked) {
      commands.add(MouseClickedCommand(reason: "Selected record in chart", componentName: model.name));
    }

    if (oldFocus != null) {
      commands.add(SetFocusCommand(componentId: oldFocus.id, focus: true, reason: "Selected record in chart"));
    } else {
      commands.add(SetFocusCommand(componentId: model.id, focus: false, reason: "Selected record in chart"));
    }

    return commands;
  }
}
