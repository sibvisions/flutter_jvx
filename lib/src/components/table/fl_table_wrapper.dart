import 'dart:collection';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_client/src/components/table/column_size_calculator.dart';
import 'package:flutter_client/src/components/table/fl_table_widget.dart';
import 'package:flutter_client/src/mixin/ui_service_mixin.dart';
import 'package:flutter_client/src/model/api/requests/api_filter_model.dart';
import 'package:flutter_client/src/model/command/api/delete_record_command.dart';
import 'package:flutter_client/src/model/command/api/insert_record_command.dart';
import 'package:flutter_client/src/model/command/api/select_record_command.dart';
import 'package:flutter_client/src/model/component/table/fl_table_model.dart';
import 'package:flutter_client/src/model/data/subscriptions/data_chunk.dart';
import 'package:flutter_client/src/model/data/subscriptions/data_record.dart';
import 'package:flutter_client/src/model/data/subscriptions/data_subscription.dart';
import 'package:flutter_client/src/model/layout/layout_data.dart';
import 'package:flutter_client/util/logging/flutter_logger.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../model/api/response/dal_meta_data_response.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';

class FlTableWrapper extends BaseCompWrapperWidget<FlTableModel> {
  static const int DEFAULT_ITEM_COUNT_PER_PAGE = 100;

  FlTableWrapper({Key? key, required String id}) : super(key: key, id: id);

  @override
  _FlTableWrapperState createState() => _FlTableWrapperState();
}

class _FlTableWrapperState extends BaseCompWrapperState<FlTableModel> with UiServiceMixin {
  /// The last touched index describes the index of the initially touched row in complex movements.
  /// This is used as a way to know which row to apply the [deleteRecord].
  int lastTouchedIndex = -1;

  DragDownDetails? _lastDragDownDetails;

  int pageCount = 1;

  int selectedRow = -1;

  DalMetaDataResponse? metaData;

  DataChunk chunkData =
      DataChunk(data: HashMap(), isAllFetched: false, columnDefinitions: [], from: 0, to: 0, update: false);

  late TableSize tableSize;

  ItemScrollController itemScrollController = ItemScrollController();

  @override
  void initState() {
    super.initState();

    layoutData.isFixedSize = true;

    tableSize = TableSize.initial((model.columnLabels ?? model.columnNames).length);

    subscribe();
  }

  @override
  Widget build(BuildContext context) {
    final FlTableWidget widget = FlTableWidget(
      model: model,
      chunkData: chunkData,
      tableSize: tableSize,
      selectedRow: selectedRow,
      onEndScroll: loadMore,
      onLongPress: showContextMenu,
      onRowSwipe: deleteRecord,
      onRowTap: selectRecord,
      onRowTapDown: onRowDown,
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
  void receiveNewLayoutData({required LayoutData newLayoutData, bool pSetState = true}) {
    super.receiveNewLayoutData(newLayoutData: newLayoutData, pSetState: false);

    recalculateTableSize(pSetState);
  }

  @override
  receiveNewModel({required FlTableModel newModel}) {
    super.receiveNewModel(newModel: newModel);
    subscribe();
  }

  void receiveTableData(DataChunk pChunkData) {
    dev.log("Received table data: ${pChunkData.data.length}");
    if (pChunkData.update) {
      for (int index in pChunkData.data.keys) {
        chunkData.data[index] = pChunkData.data[index]!;
      }
    } else {
      chunkData = pChunkData;
    }

    recalculateTableSize(true);
  }

  void recalculateTableSize([bool pSetState = false]) {
    tableSize = ColumnSizeCalculator.calculateTableSize(
      tableModel: model,
      dataChunk: chunkData,
      availableWidth: layoutData.layoutPosition?.width,
    );

    if (pSetState) {
      setState(() {});
    }
  }

  void receiveSelectedRecord(DataRecord? pRecord) {
    dev.log("Received selected record: $pRecord");

    if (pRecord != null) {
      selectedRow = pRecord.index;
    } else {
      selectedRow = -1;
    }

    setState(() {});
  }

  void receiveMetaData(DalMetaDataResponse pMetaData) {
    dev.log("Received meta data: ${pMetaData.columns.length}");

    metaData = pMetaData;
    setState(() {});
  }

  void loadMore() {
    if (!chunkData.isAllFetched) {
      pageCount++;
      subscribe();
    }
  }

  void deleteRecord() {
    if (lastTouchedIndex != -1) {
      ApiFilterModel? filter = createPrimaryFilter(pRowIndex: lastTouchedIndex);

      if (filter == null) {
        LOGGER.logW(pType: LOG_TYPE.DATA, pMessage: "Filter of table(${model.id}) null");
        return;
      }

      uiService.sendCommand(DeleteRecordCommand(
          dataProvider: model.dataBook, selectedRow: lastTouchedIndex, reason: "Swiped", filter: filter));

      lastTouchedIndex = -1;
      setState(() {});
    }
  }

  void selectRecord(int pRowIndex) {
    if (selectedRow != pRowIndex) {
      uiService
          .sendCommand(SelectRecordCommand(dataProvider: model.dataBook, selectedRecord: pRowIndex, reason: "Tapped"));

      selectedRow = pRowIndex;
      setState(() {});
    }
  }

  void insertRecord() {
    uiService.sendCommand(InsertRecordCommand(dataProvider: model.dataBook, reason: "Inserted"));
  }

  void onRowDown(int pRowIndex, DragDownDetails? pDetails) {
    if (_lastDragDownDetails != null &&
        pDetails != null &&
        _lastDragDownDetails!.globalPosition == pDetails.globalPosition &&
        pRowIndex == -1) {
      return;
    }

    _lastDragDownDetails = pDetails;
    lastTouchedIndex = pRowIndex;
    dev.log('onRowDown: $pRowIndex');
  }

  void subscribe() {
    uiService.registerDataSubscription(
      pDataSubscription: DataSubscription(
        id: model.id,
        dataProvider: model.dataBook,
        from: 0,
        to: FlTableWrapper.DEFAULT_ITEM_COUNT_PER_PAGE * pageCount,
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
  Size calculateSize(BuildContext context) {
    return tableSize.calculatedSize;
  }

  dynamic getValue({required String pColumnName, int? pRowIndex}) {
    int rowIndex = pRowIndex ?? selectedRow;
    if (rowIndex == -1) {
      return null;
    }

    int colIndex = chunkData.columnDefinitions.indexWhere((element) => element.name == pColumnName);

    if (colIndex == -1) {
      return null;
    }

    return chunkData.data[rowIndex]![colIndex];
  }

  ApiFilterModel? createPrimaryFilter({int? pRowIndex}) {
    int rowIndex = pRowIndex ?? selectedRow;
    if (rowIndex == -1 || metaData == null) {
      return null;
    }

    List<String> listColsToMap = metaData!.primaryKeyColumns;
    List<int> listColIndex = [];

    for (int i = 0; i < chunkData.columnDefinitions.length; i++) {
      if (listColsToMap.contains(chunkData.columnDefinitions[i].name)) {
        listColIndex.add(i);
      }
    }

    List<dynamic> listValues = [];
    for (int i = 0; i < listColIndex.length; i++) {
      listValues.add(chunkData.data[rowIndex]![listColIndex[i]]);
    }

    return ApiFilterModel(values: listValues, columnNames: listColsToMap);
  }

  PopupMenuItem<ContextMenuCommand> _getContextMenuItem(IconData icon, String text, ContextMenuCommand value) {
    return PopupMenuItem<ContextMenuCommand>(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          FaIcon(
            icon,
            color: Colors.grey[600],
          ),
          Padding(padding: const EdgeInsets.only(left: 5), child: Text(text)),
        ],
      ),
      enabled: true,
      value: value,
    );
  }

  showContextMenu() {
    List<PopupMenuEntry<ContextMenuCommand>> popupMenuEntries = <PopupMenuEntry<ContextMenuCommand>>[];

    if (metaData?.insertEnabled ?? true) {
      popupMenuEntries.add(_getContextMenuItem(FontAwesomeIcons.plusSquare, 'Insert', ContextMenuCommand.INSERT));
    }

    if ((metaData?.deleteEnabled ?? true) && lastTouchedIndex != -1) {
      popupMenuEntries.add(_getContextMenuItem(FontAwesomeIcons.minusSquare, 'Delete', ContextMenuCommand.DELETE));
    }

    if (_lastDragDownDetails == null) {
      return;
    }

    showMenu(
            position: RelativeRect.fromRect(
                _lastDragDownDetails!.globalPosition & const Size(40, 40), Offset.zero & MediaQuery.of(context).size),
            context: context,
            items: popupMenuEntries)
        .then((val) {
      WidgetsBinding.instance!.focusManager.primaryFocus?.unfocus();
      if (val != null) {
        if (val == ContextMenuCommand.INSERT) {
          insertRecord();
        } else if (val == ContextMenuCommand.DELETE) {
          deleteRecord();
        }
      }
    });
  }
}

enum ContextMenuCommand { INSERT, DELETE }
