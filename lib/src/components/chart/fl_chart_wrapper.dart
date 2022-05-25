import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_client/src/components/chart/fl_chart_widget.dart';
import 'package:flutter_client/src/mixin/ui_service_mixin.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../mixin/ui_service_mixin.dart';
import '../../model/component/chart/fl_chart_model.dart';
import '../../model/data/subscriptions/data_chunk.dart';
import '../../model/data/subscriptions/data_subscription.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';

class FlChartWrapper extends BaseCompWrapperWidget<FlChartModel> {
  FlChartWrapper({Key? key, required String id}) : super(key: key, id: id);

  @override
  _FlChartWrapperState createState() => _FlChartWrapperState();
}

class _FlChartWrapperState extends BaseCompWrapperState<FlChartModel> with UiServiceMixin {
  DataChunk? _chunkData;

  @override
  void initState() {
    super.initState();
    subscribe();
  }

  @override
  void receiveNewModel({required FlChartModel newModel}) {
    super.receiveNewModel(newModel: newModel);
    unsubscribe();
    subscribe();
  }

  @override
  Widget build(BuildContext context) {
    final FlChartWidget widget = FlChartWidget(
      model: model,
      series: getChartSeries(),
    );

    SchedulerBinding.instance!.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: widget);
  }

  void subscribe() {
    uiService.registerDataSubscription(
      pDataSubscription: DataSubscription(
        id: model.id,
        from: 0,
        dataProvider: model.dataProvider,
        onDataChunk: receiveChartData,
        dataColumns: getDataColumns(),
      ),
    );
  }

  void receiveChartData(DataChunk pChunkData) {
    if (pChunkData.update && _chunkData != null) {
      for (int index in pChunkData.data.keys) {
        _chunkData!.data[index] = pChunkData.data[index]!;
      }
    } else {
      _chunkData = pChunkData;
    }

    setState(() {});
  }

  List<String> getDataColumns() {
    return [model.xColumnName, ...model.yColumnNames];
  }

  List<ChartSeries> getChartSeries() {
    if (_chunkData == null) {
      return [];
    }

    DataChunk chunkData = _chunkData!;

    List<ChartSeries> seriesList = [];
    int xColumnIndex = chunkData.columnDefinitions.indexWhere((element) => element.name == model.xColumnName);

    for (String column in model.yColumnNames) {
      int yColumnIndex = chunkData.columnDefinitions.indexWhere((element) => element.name == column);

      seriesList.add(
        AreaSeries<dynamic, num>(
          opacity: 0.5,
          dataSource: chunkData.data.keys.toList(),
          xValueMapper: (_, index) => chunkData.data[index]![xColumnIndex],
          yValueMapper: (_, index) => chunkData.data[index]![yColumnIndex],
          legendItemText: model.yColumnLabels[model.yColumnNames.indexOf(column)],
          xAxisName: model.xAxisTitle,
          yAxisName: model.yAxisTitle,
        ),
      );
    }

    return seriesList;
  }

  void unsubscribe() {
    uiService.disposeDataSubscription(pComponentId: model.id, pDataProvider: model.dataProvider);
  }
}
