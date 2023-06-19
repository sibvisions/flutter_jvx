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

import 'package:community_charts_flutter/community_charts_flutter.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../flutter_ui.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/data/subscriptions/data_chunk.dart';
import '../../model/data/subscriptions/data_subscription.dart';
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
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return wrapWidget(child: widget);
  }

  void subscribe() {
    var columnNames = getDataColumns();

    if (columnNames.isNotEmpty) {
      IUiService().registerDataSubscription(
        pDataSubscription: DataSubscription(
          subbedObj: this,
          from: 0,
          dataProvider: model.dataProvider,
          onDataChunk: receiveChartData,
          dataColumns: getDataColumns(),
        ),
      );
    }
  }

  void receiveChartData(DataChunk pChunkData) {
    _chunkData = pChunkData;

    setState(() {});
  }

  List<String> getDataColumns() {
    return [model.xColumnName, ...model.yColumnNames]..removeWhere((element) => element.isEmpty);
  }

  List<Series<dynamic, num>> getChartSeries() {
    if (_chunkData == null) {
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
          data: chunkData.data.values.toList(),
          domainFn: (data, index) => createXData(data, index, xColumnIndex),
          measureFn: (data, index) => createYData(data, index, yColumnIndex),
        ),
      );
    }

    return seriesList;
  }

  num createYData(dynamic pData, int? pIndex, int pColumnIndex) {
    if (pData.length <= pColumnIndex) {
      FlutterUI.logUI.e("Chart error: ColumnIndex is: $pColumnIndex, Datalist lenght is: ${pData.length}");
      return pIndex ?? 0;
    }

    dynamic value = pData[pColumnIndex];
    if (value is num) {
      return value;
    } else {
      return double.tryParse(value) ?? 0.0;
    }
  }

  num createXData(dynamic pData, int? pIndex, int pColumnIndex) {
    if (pData.length <= pColumnIndex) {
      FlutterUI.logUI.e("Chart error: ColumnIndex is: $pColumnIndex, Datalist lenght is: ${pData.length}");
      return pIndex ?? 0;
    }

    dynamic value = pData[pColumnIndex];
    if (value is num) {
      return value;
    } else {
      return double.tryParse(value) ?? pIndex ?? 0.0;
    }
  }

  void unsubscribe() {
    IUiService().disposeDataSubscription(pSubscriber: this, pDataProvider: model.dataProvider);
  }
}
