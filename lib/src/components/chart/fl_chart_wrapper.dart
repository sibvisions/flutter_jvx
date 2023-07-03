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

import 'package:collection/collection.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../flutter_ui.dart';
import '../../model/command/api/mouse_clicked_command.dart';
import '../../model/command/api/mouse_pressed_command.dart';
import '../../model/command/api/mouse_released_command.dart';
import '../../model/command/api/select_record_command.dart';
import '../../model/command/base_command.dart';
import '../../model/command/ui/set_focus_command.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/data/data_book.dart';
import '../../model/data/subscriptions/data_chunk.dart';
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
  DataChunk? _chunkData;

  DalMetaData? _metaData;

  _FlChartWrapperState() : super();

  @override
  void initState() {
    super.initState();
    subscribe();
  }

  @override
  void modelUpdated() {
    super.modelUpdated();
    unsubscribe();
    subscribe();
  }

  @override
  Widget build(BuildContext context) {
    final FlChartWidget widget = FlChartWidget(
      model: model,
      series: getChartSeries(),
      onIndexSelected: onIndexSelected,
    );
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
          onMetaData: receiveMetaData,
        ),
      );
    }
  }

  void receiveMetaData(DalMetaData pMetaData) {
    _metaData = pMetaData;

    setState(() {});
  }

  void receiveChartData(DataChunk pChunkData) {
    _chunkData = pChunkData;

    setState(() {});
  }

  List<Series<dynamic, num>> getChartSeries() {
    if (_chunkData == null || _metaData == null) {
      return [];
    }

    DataChunk chunkData = _chunkData!;

    List<Series<dynamic, num>> seriesList = [];
    int xColumnIndex = chunkData.columnDefinitions.indexWhere((element) => element.name == model.xColumnName);

    for (String column in model.yColumnNames) {
      int yColumnIndex = chunkData.columnDefinitions.indexWhere((element) => element.name == column);

      seriesList.add(
        Series<dynamic, num>(
          id: model.name,
          data: chunkData.data.entries.sorted((a, b) => a.key.compareTo(b.key)),
          domainFn: (mapEntry, _) => createXData(mapEntry.key, xColumnIndex),
          measureFn: (mapEntry, _) => createYData(mapEntry.key, yColumnIndex),
        ),
      );
    }

    return seriesList;
  }

  num createYData(int? pIndex, int pColumnIndex) {
    var data = _chunkData!.data[pIndex]!;

    if (data.length <= pColumnIndex) {
      FlutterUI.logUI.e("Chart error: ColumnIndex is: $pColumnIndex, Datalist lenght is: ${data.length}");
      return pIndex ?? 0;
    }

    dynamic value = data[pColumnIndex];
    if (value is num) {
      return value;
    } else {
      return double.tryParse(value) ?? 0.0;
    }
  }

  num createXData(int? pIndex, int pColumnIndex) {
    var data = _chunkData!.data[pIndex]!;

    if (data.length <= pColumnIndex) {
      FlutterUI.logUI.e("Chart error: ColumnIndex is: $pColumnIndex, Datalist lenght is: ${data.length}");
      return pIndex ?? 0;
    }

    dynamic value = data[pColumnIndex];
    if (value is num) {
      return value;
    } else {
      return double.tryParse(value) ?? pIndex ?? 0.0;
    }
  }

  void unsubscribe() {
    IUiService().disposeDataSubscription(pSubscriber: this, pDataProvider: model.dataProvider);
  }

  void onIndexSelected(int? pIndex) {
    if (_chunkData == null || _metaData == null) {
      return;
    }

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
                    columnNames: _metaData!.primaryKeyColumns,
                    values: _metaData!.primaryKeyColumns
                        .map((columnName) => _chunkData!.data[pIndex]![
                            _chunkData!.columnDefinitions.indexWhere((colDef) => colDef.name == columnName)])
                        .toList(),
                  ),
                  rowNumber: pIndex,
                ),
              );
            } else {
              commands.add(
                SelectRecordCommand.deselect(
                  reason: "Selected record in chart",
                  dataProvider: model.dataProvider,
                ),
              );
            }

            commands.addAll([
              MousePressedCommand(reason: "Selected record in chart", componentName: model.id),
              MouseReleasedCommand(reason: "Selected record in chart", componentName: model.id),
              MouseClickedCommand(reason: "Selected record in chart", componentName: model.id)
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
