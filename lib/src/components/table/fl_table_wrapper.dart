import 'dart:collection';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_client/src/components/table/column_size_calculator.dart';
import 'package:flutter_client/src/components/table/fl_table_widget.dart';
import 'package:flutter_client/src/mixin/ui_service_mixin.dart';
import 'package:flutter_client/src/model/component/table/fl_table_model.dart';
import 'package:flutter_client/src/model/data/subscriptions/data_chunk.dart';
import 'package:flutter_client/src/model/data/subscriptions/data_record.dart';
import 'package:flutter_client/src/model/data/subscriptions/data_subscription.dart';

import '../../model/api/response/dal_meta_data_response.dart';
import '../../model/layout/layout_data.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';

class FlTableWrapper extends BaseCompWrapperWidget<FlTableModel> {
  FlTableWrapper({Key? key, required String id}) : super(key: key, id: id);

  @override
  _FlTableWrapperState createState() => _FlTableWrapperState();
}

class _FlTableWrapperState extends BaseCompWrapperState<FlTableModel> with UiServiceMixin {
  int lastTouchedIndex = -1;

  int pageCount = 1;

  int selectedRow = -1;

  DalMetaDataResponse? metaData;

  DataChunk chunkData =
      DataChunk(data: HashMap(), isAllFetched: false, columnDefinitions: [], from: 0, to: 0, update: false);

  late TableSize tableSize;

  @override
  void initState() {
    super.initState();

    tableSize = TableSize.initial((model.columnLabels ?? model.columnNames).length);

    subscribe();
  }

  @override
  Widget build(BuildContext context) {
    final FlTableWidget widget = FlTableWidget(
      model: model,
      chunkData: chunkData,
      tableWidth: tableSize.getTableSize(model),
      onEndScroll: onEndScroll,
      onLongPress: onLongPress,
      onRowSwipe: onRowSwipe,
      onRowTap: onRowTap,
      onRowTapDown: onRowDown,
      columnSizes: tableSize.columnWidths,
    );

    SchedulerBinding.instance!.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: widget);
  }

  @override
  void dispose() {
    unsubscribe();
    super.dispose();
  }

  @override
  receiveNewModel({required FlTableModel newModel}) {
    super.receiveNewModel(newModel: newModel);
    unsubscribe();
    pageCount = 1;
    subscribe();
  }

  void receiveTableData(DataChunk pChunkData) {
    if (pChunkData.update) {
      for (int index in pChunkData.data.keys) {
        chunkData.data[index] = pChunkData.data[index]!;
      }
    } else {
      chunkData = pChunkData;
    }

    tableSize = ColumnSizeCalculator.calculateTableSize(
      tableModel: model,
      dataChunk: chunkData,
    );

    setState(() {});
  }

  void receiveSelectedRecord(DataRecord? pRecord) {
    if (pRecord != null) {
      selectedRow = pRecord.index;
    } else {
      selectedRow = -1;
    }

    setState(() {});
  }

  void receiveMetaData(DalMetaDataResponse pMetaData) {
    metaData = pMetaData;
    setState(() {});
  }

  void onEndScroll() {
    dev.log("end scroll");
    pageCount++;
    subscribe();
  }

  void onLongPress() {
    // TODO
  }

  void onRowSwipe(int pRowIndex) {
    // TODO
  }

  void onRowTap(int pRowIndex) {
    // TODO
  }

  void onRowDown(int pRowIndex) {
    lastTouchedIndex = pRowIndex;
    dev.log('onRowDown: $pRowIndex');
  }

  void subscribe() {
    uiService.registerDataSubscription(
      pDataSubscription: DataSubscription(
        id: model.id,
        dataProvider: model.dataBook,
        from: 0,
        to: 100 * pageCount,
        onSelectedRecord: receiveSelectedRecord,
        onDataChunk: receiveTableData,
        onMetaData: receiveMetaData,
        dataColumns: null,
      ),
    );
  }

  void unsubscribe() {
    uiService.disposeSubscriptions(pComponentId: model.id);
  }

  @override
  void sendCalcSize({required LayoutData pLayoutData, required String pReason}) {
    if (pLayoutData.hasCalculatedSize) {
      pLayoutData = pLayoutData.clone();

      layoutData.calculatedSize = const Size(500, 500);
    }

    super.sendCalcSize(pLayoutData: pLayoutData, pReason: pReason);
  }
}
