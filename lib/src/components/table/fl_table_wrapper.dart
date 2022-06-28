import 'dart:collection';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_client/src/model/command/api/set_values_command.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../util/logging/flutter_logger.dart';
import '../../mixin/ui_service_mixin.dart';
import '../../model/api/requests/api_filter_model.dart';
import '../../model/api/response/dal_meta_data_response.dart';
import '../../model/command/api/delete_record_command.dart';
import '../../model/command/api/insert_record_command.dart';
import '../../model/command/api/select_record_command.dart';
import '../../model/component/table/fl_table_model.dart';
import '../../model/data/subscriptions/data_chunk.dart';
import '../../model/data/subscriptions/data_record.dart';
import '../../model/data/subscriptions/data_subscription.dart';
import '../../model/layout/layout_data.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';
import 'column_size_calculator.dart';
import 'fl_table_widget.dart';

class FlTableWrapper extends BaseCompWrapperWidget<FlTableModel> {
  static const int DEFAULT_ITEM_COUNT_PER_PAGE = 100;

  FlTableWrapper({Key? key, required String id}) : super(key: key, id: id);

  @override
  _FlTableWrapperState createState() => _FlTableWrapperState();
}

class _FlTableWrapperState extends BaseCompWrapperState<FlTableModel> with UiServiceMixin {
  static const int LOADED_META_DATA = 1;
  static const int LOADED_SELECTED_RECORD = 2;
  static const int LOADED_DATA = 4;
  static const int CALCULATION_COMPLETE = 8;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  int currentState = 0;

  /// The last touched index describes the index of the initially touched row in complex movements.
  /// This is used as e.g. a way to know which row to apply the [deleteRecord].
  int lastTouchedIndex = -1;

  /// The last position of the tab of the table.
  DragDownDetails? _lastDragDownDetails;

  /// How many "pages" of the table data have been loaded multiplied by: [FlTableWrapper.DEFAULT_ITEM_COUNT_PER_PAGE]
  int pageCount = 1;

  /// The currently selected row. -1 is none selected.
  int selectedRow = -1;

  /// The meta data of the table.
  DalMetaDataResponse? metaData;

  /// The data of the table.
  DataChunk chunkData =
      DataChunk(data: HashMap(), isAllFetched: false, columnDefinitions: [], from: 0, to: 0, update: false);

  /// The sizes of the table.
  late TableSize tableSize;

  /// The item scroll controller.
  ItemScrollController itemScrollController = ItemScrollController();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    dev.log("initState this: $hashCode");
    super.initState();

    layoutData.isFixedSize = true;

    tableSize = TableSize.initial((model.columnLabels ?? model.columnNames).length);

    subscribe();
  }

  @override
  Widget build(BuildContext context) {
    dev.log("build this: $hashCode");

    Widget? widget;
    if (currentState != (LOADED_META_DATA | LOADED_SELECTED_RECORD | LOADED_DATA | CALCULATION_COMPLETE)) {
      widget = const CircularProgressIndicator();
    }

    widget ??= FlTableWidget(
      model: model,
      metaData: metaData,
      chunkData: chunkData,
      tableSize: tableSize,
      selectedRow: selectedRow,
      onEndEditing: setValueEnd,
      onValueChanged: setValueChanged,
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
    dev.log("dispose this: $hashCode");
    unsubscribe();
    super.dispose();
  }

  @override
  void receiveNewLayoutData({required LayoutData newLayoutData, bool pSetState = true}) {
    dev.log("receiveNewLayoutData this: $hashCode");
    super.receiveNewLayoutData(newLayoutData: newLayoutData, pSetState: false);

    recalculateTableSize(pSetState);
  }

  @override
  receiveNewModel({required FlTableModel newModel}) {
    dev.log("receiveNewModel this: $hashCode");
    super.receiveNewModel(newModel: newModel);
    subscribe();
  }

  @override
  Size calculateSize(BuildContext context) {
    dev.log("calculateSize this: $hashCode");
    return tableSize.calculatedSize;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Recalculates the size of the table.
  void recalculateTableSize([bool pSetState = false]) {
    dev.log("recalculateTableSize this: $hashCode");
    tableSize = ColumnSizeCalculator.calculateTableSize(
      tableModel: model,
      dataChunk: chunkData,
      availableWidth: layoutData.layoutPosition?.width,
    );

    currentState = currentState | CALCULATION_COMPLETE;

    if (pSetState) {
      setState(() {});
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Data methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Subscribes to the data service.
  void subscribe() {
    uiService.registerDataSubscription(
      pDataSubscription: DataSubscription(
        subbedObj: this,
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

  /// Unsubscribes from the data service.
  void unsubscribe() {
    uiService.disposeDataSubscription(pSubscriber: this, pDataProvider: model.dataBook);
  }

  /// Loads data from the server.
  void receiveTableData(DataChunk pChunkData) {
    currentState = currentState | LOADED_DATA;

    bool hasToCalc = false;
    if (pChunkData.update) {
      for (int index in pChunkData.data.keys) {
        chunkData.data[index] = pChunkData.data[index]!;
      }
    } else {
      hasToCalc = chunkData.columnDefinitions.isEmpty && chunkData.data.isEmpty && pChunkData.to == 0;

      chunkData = pChunkData;
    }

    if (hasToCalc) {
      recalculateTableSize(true);
    }
  }

  /// Receives which row is selected.
  void receiveSelectedRecord(DataRecord? pRecord) {
    currentState = currentState | LOADED_SELECTED_RECORD;

    if (pRecord != null) {
      selectedRow = pRecord.index;
    } else {
      selectedRow = -1;
    }

    setState(() {});
  }

  /// Receives the meta data of the table.
  void receiveMetaData(DalMetaDataResponse pMetaData) {
    // Future.delayed(
    //   const Duration(seconds: 5),
    //   () {
    currentState = currentState | LOADED_META_DATA;

    metaData = pMetaData;
    setState(() {});
    //   },
    // );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Action methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Increments the page count and loads more data.
  void loadMore() {
    if (!chunkData.isAllFetched) {
      pageCount++;
      subscribe();
    }
  }

  /// Deletes the selected record.
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

  /// Selects the record.
  void selectRecord(int pRowIndex) {
    // if (selectedRow != pRowIndex) {
    ApiFilterModel? filter = createPrimaryFilter(pRowIndex: pRowIndex);

    if (filter == null) {
      LOGGER.logW(pType: LOG_TYPE.DATA, pMessage: "Filter of table(${model.id}) null");
      return;
    }

    uiService.sendCommand(
        SelectRecordCommand(dataProvider: model.dataBook, selectedRecord: pRowIndex, reason: "Tapped", filter: filter));
    setState(() {});
    // }
  }

  /// Saves the last touched row.
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
        _lastDragDownDetails!.globalPosition & const Size(40, 40),
        Offset.zero & MediaQuery.of(context).size,
      ),
      context: context,
      items: popupMenuEntries,
    ).then((val) {
      WidgetsBinding.instance!.focusManager.primaryFocus?.unfocus();

      if (val == ContextMenuCommand.INSERT) {
        insertRecord();
      } else if (val == ContextMenuCommand.DELETE) {
        deleteRecord();
      }
    });
  }

  void setValueEnd(dynamic pValue, int pRow, String pColumnName) {
    int colIndex = metaData?.columns.indexWhere((element) => element.name == pColumnName) ?? -1;

    if (colIndex >= 0 && pRow >= 0 && pRow < chunkData.data.length && colIndex < chunkData.data[pRow]!.length) {
      if (pValue is HashMap<String, dynamic>) {
        sendRow(pRow, pValue.keys.toList(), pValue.values.toList());
      } else {
        sendRow(pRow, [pColumnName], [pValue]);
      }
    }
  }

  void setValueChanged(dynamic pValue, int pRow, String pColumnName) {
    // Do nothing
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void sendRow(int? pRowIndex, List<String>? pColumnNames, List<dynamic> pValues) {
    int rowIndex = pRowIndex ?? selectedRow;
    if (rowIndex < 0 || rowIndex >= chunkData.data.length) {
      return;
    }

    if (rowIndex != selectedRow) {
      // selectRecord(rowIndex);
    }

    List<String> columnNames = pColumnNames ?? metaData!.columns.map((e) => e.name).toList();

    uiService.sendCommand(
      SetValuesCommand(
        componentId: model.id,
        dataProvider: model.dataBook,
        columnNames: columnNames,
        values: pValues,
        reason: "Values changed in table",
      ),
    );
  }

  /// Inserts a new record.
  void insertRecord() {
    uiService.sendCommand(InsertRecordCommand(dataProvider: model.dataBook, reason: "Inserted"));
  }

  dynamic getValue({required String pColumnName, int? pRowIndex}) {
    int rowIndex = pRowIndex ?? selectedRow;
    if (rowIndex == -1) {
      return;
    }

    int colIndex = chunkData.columnDefinitions.indexWhere((element) => element.name == pColumnName);

    if (colIndex == -1) {
      return;
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
}

enum ContextMenuCommand { INSERT, DELETE }
