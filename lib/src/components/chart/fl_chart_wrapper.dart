import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_client/src/components/chart/fl_chart_widget.dart';
import 'package:flutter_client/src/mixin/ui_service_mixin.dart';

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
        subbedObj: this,
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
          data: chunkData.data.keys.toList(),
          domainFn: (_, index) => chunkData.data[index]![xColumnIndex],
          measureFn: (_, index) => chunkData.data[index]![yColumnIndex],
        ),
      );
    }

    return seriesList;
  }

  void unsubscribe() {
    uiService.disposeDataSubscription(pSubscriber: this, pDataProvider: model.dataProvider);
  }
}
