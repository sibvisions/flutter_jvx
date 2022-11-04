import 'dart:collection';

import 'package:beamer/beamer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../flutter_jvx.dart';
import '../../../services.dart';
import '../../model/command/api/delete_record_command.dart';
import '../../model/command/api/insert_record_command.dart';
import '../../model/command/api/select_record_command.dart';
import '../../model/command/api/set_values_command.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/component/table/fl_table_model.dart';
import '../../model/data/subscriptions/data_chunk.dart';
import '../../model/data/subscriptions/data_record.dart';
import '../../model/data/subscriptions/data_subscription.dart';
import '../../model/layout/layout_data.dart';
import '../../model/request/filter.dart';
import '../../model/response/dal_meta_data_response.dart';
import '../../service/api/shared/fl_component_classname.dart';
import '../../util/offline_util.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';
import 'fl_table_widget.dart';
import 'table_size.dart';

class FlTableWrapper extends BaseCompWrapperWidget<FlTableModel> {
  static const int DEFAULT_ITEM_COUNT_PER_PAGE = 100;

  const FlTableWrapper({Key? key, required String id}) : super(key: key, id: id);

  @override
  BaseCompWrapperState<FlComponentModel> createState() => _FlTableWrapperState();
}

class _FlTableWrapperState extends BaseCompWrapperState<FlTableModel> {
  static const int LOADED_META_DATA = 1;
  static const int LOADED_SELECTED_RECORD = 2;
  static const int LOADED_DATA = 4;
  static const int CALCULATION_COMPLETE = 8;
  static const int ALL_COMPLETE = 15;

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

  /// The scroll controller for the table.
  late final ScrollController tableHorizontalController;

  /// The scroll controller for the headers if they are set to sticky.
  late final ScrollController headerHorizontalController;

  /// The item scroll controller.
  final ItemScrollController itemScrollController = ItemScrollController();

  /// The scroll group to synchronize sticky header scrolling.
  final LinkedScrollControllerGroup linkedScrollGroup = LinkedScrollControllerGroup();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    super.initState();

    layoutData.isFixedSize = true;

    tableSize = TableSize.direct(tableModel: model, dataChunk: chunkData);

    tableHorizontalController = linkedScrollGroup.addAndGet();
    headerHorizontalController = linkedScrollGroup.addAndGet();

    subscribe();
  }

  @override
  Widget build(BuildContext context) {
    Widget? widget;
    if (currentState != (ALL_COMPLETE)) {
      widget = const Center(child: CircularProgressIndicator());
    }

    widget ??= FlTableWidget(
      headerHorizontalController: headerHorizontalController,
      itemScrollController: itemScrollController,
      tableHorizontalController: tableHorizontalController,
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

    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: widget);
  }

  @override
  void dispose() {
    unsubscribe();

    tableHorizontalController.dispose();
    headerHorizontalController.dispose();
    super.dispose();
  }

  @override
  void receiveNewLayoutData(LayoutData pLayoutData, [bool pSetState = true]) {
    super.receiveNewLayoutData(pLayoutData, pSetState);

    recalculateTableSize(pSetState);
  }

  @override
  receiveNewModel(FlTableModel pModel) {
    super.receiveNewModel(pModel);
    subscribe();
  }

  @override
  Size calculateSize(BuildContext context) {
    return tableSize.calculatedSize;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Recalculates the size of the table.
  void recalculateTableSize([bool pSetState = false]) {
    tableSize.calculateTableSize(
      pTableModel: model,
      pDataChunk: chunkData,
      pAvailableWidth: layoutData.layoutPosition?.width,
    );

    currentState |= CALCULATION_COMPLETE;

    if (pSetState) {
      setState(() {});
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Data methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Subscribes to the data service.
  void subscribe() {
    if (model.dataProvider.isNotEmpty) {
      IUiService().registerDataSubscription(
        pDataSubscription: DataSubscription(
          subbedObj: this,
          dataProvider: model.dataProvider,
          from: 0,
          to: FlTableWrapper.DEFAULT_ITEM_COUNT_PER_PAGE * pageCount,
          onSelectedRecord: receiveSelectedRecord,
          onDataChunk: receiveTableData,
          onMetaData: receiveMetaData,
          dataColumns: null,
        ),
      );
    } else {
      currentState |= LOADED_META_DATA;
      currentState |= LOADED_DATA;
      currentState |= LOADED_SELECTED_RECORD;
    }
  }

  /// Unsubscribes from the data service.
  void unsubscribe() {
    IUiService().disposeDataSubscription(pSubscriber: this, pDataProvider: model.dataProvider);

    currentState &= ~LOADED_META_DATA;
    currentState &= ~LOADED_DATA;
    currentState &= ~LOADED_SELECTED_RECORD;
  }

  /// Loads data from the server.
  void receiveTableData(DataChunk pChunkData) {
    currentState |= LOADED_DATA;

    bool hasToCalc = false;
    if (pChunkData.update) {
      for (int index in pChunkData.data.keys) {
        chunkData.data[index] = pChunkData.data[index]!;
      }
    } else {
      hasToCalc = chunkData.columnDefinitions.isEmpty && chunkData.data.isEmpty && chunkData.to == 0;

      chunkData = pChunkData;
    }

    if (hasToCalc) {
      recalculateTableSize(true);
    }
  }

  /// Receives which row is selected.
  void receiveSelectedRecord(DataRecord? pRecord) {
    currentState |= LOADED_SELECTED_RECORD;

    if (pRecord != null) {
      selectedRow = pRecord.index;
    } else {
      selectedRow = -1;
    }

    setState(() {});
  }

  /// Receives the meta data of the table.
  void receiveMetaData(DalMetaDataResponse pMetaData) {
    currentState |= LOADED_META_DATA;

    metaData = pMetaData;
    recalculateTableSize(true);
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
      Filter? filter = createFilter(pRowIndex: lastTouchedIndex);

      if (filter == null) {
        FlutterJVx.logUI.w("Filter of table(${model.id}) null");
        return;
      }

      IUiService().sendCommand(DeleteRecordCommand(
        dataProvider: model.dataProvider,
        selectedRow: lastTouchedIndex,
        reason: "Swiped",
        filter: filter,
      ));

      lastTouchedIndex = -1;
      setState(() {});
    }
  }

  /// Selects the record.
  Future<void> selectRecord(int pRowIndex) async {
    // if (selectedRow != pRowIndex) {
    Filter? filter = createFilter(pRowIndex: pRowIndex);

    if (filter == null) {
      FlutterJVx.logUI.w("Filter of table(${model.id}) null");
      return;
    }

    return IUiService().sendCommand(SelectRecordCommand(
        dataProvider: model.dataProvider, selectedRecord: pRowIndex, reason: "Tapped", filter: filter));
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
  }

  showContextMenu() {
    List<PopupMenuEntry<ContextMenuCommand>> popupMenuEntries = <PopupMenuEntry<ContextMenuCommand>>[];

    if (metaData?.insertEnabled ?? true) {
      popupMenuEntries.add(_getContextMenuItem(FontAwesomeIcons.squarePlus, "New", ContextMenuCommand.NEW));
    }

    if ((metaData?.deleteEnabled ?? true) && lastTouchedIndex != -1) {
      popupMenuEntries.add(_getContextMenuItem(FontAwesomeIcons.squareMinus, "Delete", ContextMenuCommand.DELETE));
    }

    if (kDebugMode) {
      popupMenuEntries.add(_getContextMenuItem(FontAwesomeIcons.powerOff, "Offline", ContextMenuCommand.OFFLINE));
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
      IUiService().saveAllEditorsThen(model.id, () {
        if (val == ContextMenuCommand.NEW) {
          insertRecord();
        } else if (val == ContextMenuCommand.DELETE) {
          deleteRecord();
        } else if (val == ContextMenuCommand.OFFLINE) {
          goOffline();
        }
      }, "Table menu item pressed");
    });
  }

  void setValueEnd(dynamic pValue, int pRow, String pColumnName) {
    selectRecord(pRow).then((value) {
      int colIndex = metaData?.columns.indexWhere((element) => element.name == pColumnName) ?? -1;

      if (colIndex >= 0 && pRow >= 0 && pRow < chunkData.data.length && colIndex < chunkData.data[pRow]!.length) {
        if (pValue is HashMap<String, dynamic>) {
          sendRow(pRow, pValue.keys.toList(), pValue.values.toList());
        } else {
          sendRow(pRow, [pColumnName], [pValue]);
        }
      }
    });
  }

  void setValueChanged(dynamic pValue, int pRow, String pColumnName) {
    // Do nothing
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void sendRow(int? pRowIndex, List<String> pColumnNames, List<dynamic> pValues) {
    int rowIndex = pRowIndex ?? selectedRow;
    if (rowIndex < 0 || rowIndex >= chunkData.data.length) {
      return;
    }

    IUiService().sendCommand(
      SetValuesCommand(
        componentId: model.id,
        dataProvider: model.dataProvider,
        columnNames: pColumnNames,
        values: pValues,
        filter: createFilter(pRowIndex: rowIndex),
        reason: "Values changed in table",
      ),
    );
  }

  /// Inserts a new record.
  void insertRecord() {
    IUiService().sendCommand(InsertRecordCommand(dataProvider: model.dataProvider, reason: "Inserted"));
  }

  dynamic _getValue({required String pColumnName, int? pRowIndex}) {
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

  Filter? createFilter({int? pRowIndex}) {
    int rowIndex = pRowIndex ?? selectedRow;
    if (rowIndex == -1 || metaData == null) {
      return null;
    }

    List<String> listColumnNames = [];
    List<dynamic> listValues = [];

    if (metaData!.primaryKeyColumns.isNotEmpty) {
      listColumnNames.addAll(metaData!.primaryKeyColumns);
    } else if (metaData!.primaryKeyColumns.contains("ID")) {
      listColumnNames.add("ID");
    } else {
      listColumnNames.addAll(
        metaData!.columns
            .where((column) =>
                column.cellEditorClassName == FlCellEditorClassname.TEXT_CELL_EDITOR ||
                column.cellEditorClassName == FlCellEditorClassname.NUMBER_CELL_EDITOR)
            .map((column) => column.name),
      );
    }

    for (String column in listColumnNames) {
      listValues.add(_getValue(pColumnName: column, pRowIndex: rowIndex));
    }

    return Filter(values: listValues, columnNames: listColumnNames);
  }

  PopupMenuItem<ContextMenuCommand> _getContextMenuItem(IconData icon, String text, ContextMenuCommand value) {
    return PopupMenuItem<ContextMenuCommand>(
      enabled: true,
      value: value,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          FaIcon(
            icon,
            color: Colors.grey[600],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Text(
              FlutterJVx.translate(
                text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void goOffline() {
    BeamState state = context.currentBeamLocation.state as BeamState;
    String workscreenName = state.pathParameters['workScreenName']!;
    OfflineUtil.initOffline(workscreenName);
  }
}

enum ContextMenuCommand { NEW, DELETE, OFFLINE }
