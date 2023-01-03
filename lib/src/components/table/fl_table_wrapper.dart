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

import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../flutter_jvx.dart';
import '../../model/command/api/sort_command.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/data/sort_definition.dart';
import '../../model/layout/layout_data.dart';
import '../../util/offline_util.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';
import '../editor/cell_editor/i_cell_editor.dart';

class FlTableWrapper extends BaseCompWrapperWidget<FlTableModel> {
  static const int DEFAULT_ITEM_COUNT_PER_PAGE = 100;

  const FlTableWrapper({super.key, required super.model});

  @override
  BaseCompWrapperState<FlComponentModel> createState() => _FlTableWrapperState();
}

class _FlTableWrapperState extends BaseCompWrapperState<FlTableModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The bit signaling the meta data has been loaded.
  static const int LOADED_META_DATA = 1;

  /// The bit signaling the selected data has been loaded.
  static const int LOADED_SELECTED_RECORD = 2;

  /// The bit signaling the data has been loaded.
  static const int LOADED_DATA = 4;

  /// The bit signaling the table size has been loaded.
  static const int CALCULATION_COMPLETE = 8;

  /// The result of all being loaded.
  static const int ALL_COMPLETE = 15;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The current status of the table wrapper.
  int currentState = 0;

  /// How many "pages" of the table data have been loaded multiplied by: [FlTableWrapper.DEFAULT_ITEM_COUNT_PER_PAGE]
  int pageCount = 1;

  /// The currently selected row. -1 is none selected.
  int selectedRow = -1;

  /// The meta data of the table.
  DalMetaDataResponse? metaData;

  /// The data of the table.
  DataChunk dataChunk =
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

  /// If deletion of a row is allowed.
  bool get _isDeleteEnabled => metaData?.deleteEnabled ?? true;

  /// If inserting a row is allowed.
  bool get _isInsertEnabled => metaData?.insertEnabled ?? true;

  /// If update a row is allowed.
  bool get _isUpdateAllowed => metaData?.updateEnabled ?? true;
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  _FlTableWrapperState() : super();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    super.initState();

    layoutData.isFixedSize = true;

    tableSize = TableSize.direct(tableModel: model, dataChunk: dataChunk);

    tableHorizontalController = linkedScrollGroup.addAndGet();
    headerHorizontalController = linkedScrollGroup.addAndGet();

    _subscribe();
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
      chunkData: dataChunk,
      tableSize: tableSize,
      selectedRowIndex: selectedRow,
      onEndEditing: _setValueEnd,
      onValueChanged: _setValueChanged,
      onEndScroll: _loadMore,
      onLongPress: _onLongPress,
      onTap: _onCellTap,
      onDoubleTap: _onCellDoubleTap,
      onAction: _onAction,
      showFloatingButton: _isInsertEnabled &&
          ((layoutData.layoutPosition?.height ?? 0.0) >= 150) &&
          ((layoutData.layoutPosition?.width ?? 0.0) >= 100) &&
          model.showFloatButton,
      floatingOnPress: _insertRecord,
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: widget);
  }

  @override
  void dispose() {
    _unsubscribe();

    tableHorizontalController.dispose();
    headerHorizontalController.dispose();
    super.dispose();
  }

  @override
  void receiveNewLayoutData(LayoutData pLayoutData, [bool pSetState = true]) {
    bool newConstraint = pLayoutData.layoutPosition?.width != layoutData.layoutPosition?.width;
    super.receiveNewLayoutData(pLayoutData, pSetState);

    if (newConstraint) {
      _recalculateTableSize(pSetState);
    }
  }

  @override
  modelUpdated() {
    super.modelUpdated();

    _subscribe();

    if (model.lastChangedProperties.contains(ApiObjectProperty.columnNames) ||
        model.lastChangedProperties.contains(ApiObjectProperty.columnLabels)) {
      _recalculateTableSize(true);
    }
  }

  @override
  Size calculateSize(BuildContext context) {
    return tableSize.calculatedSize;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Recalculates the size of the table.
  void _recalculateTableSize([bool pSetState = false]) {
    tableSize.calculateTableSize(
      pTableModel: model,
      pDataChunk: dataChunk,
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
  void _subscribe() {
    if (model.dataProvider.isNotEmpty) {
      IUiService().registerDataSubscription(
        pDataSubscription: DataSubscription(
          subbedObj: this,
          dataProvider: model.dataProvider,
          from: 0,
          to: FlTableWrapper.DEFAULT_ITEM_COUNT_PER_PAGE * pageCount,
          onSelectedRecord: _receiveSelectedRecord,
          onDataChunk: _receiveTableData,
          onMetaData: _receiveMetaData,
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
  void _unsubscribe() {
    IUiService().disposeDataSubscription(pSubscriber: this, pDataProvider: model.dataProvider);

    currentState &= ~LOADED_META_DATA;
    currentState &= ~LOADED_DATA;
    currentState &= ~LOADED_SELECTED_RECORD;
  }

  /// Loads data from the server.
  void _receiveTableData(DataChunk pDataChunk) {
    currentState |= LOADED_DATA;

    List<String> newColumns = pDataChunk.columnDefinitions.map((e) => e.name).toList();
    List<String> oldColumns = dataChunk.columnDefinitions.map((e) => e.name).toList();
    bool hasToCalc = newColumns.any((element) => (!oldColumns.contains(element))) ||
        oldColumns.any((element) => (!newColumns.contains(element)));

    if (pDataChunk.update) {
      for (int index in pDataChunk.data.keys) {
        dataChunk.data[index] = pDataChunk.data[index]!;
      }
    } else {
      dataChunk = pDataChunk;
    }

    if (hasToCalc) {
      _recalculateTableSize(true);
    }
  }

  /// Receives which row is selected.
  void _receiveSelectedRecord(DataRecord? pRecord) {
    currentState |= LOADED_SELECTED_RECORD;

    if (pRecord != null) {
      selectedRow = pRecord.index;
    } else {
      selectedRow = -1;
    }

    setState(() {});
  }

  /// Receives the meta data of the table.
  void _receiveMetaData(DalMetaDataResponse pMetaData) {
    currentState |= LOADED_META_DATA;

    List<ColumnDefinition> newColumns = pMetaData.columns;
    List<ColumnDefinition> oldColumns = metaData?.columns ?? [];

    bool hasToCalc = newColumns.any((newColumn) => (!oldColumns.any((oldColumn) => newColumn.name == oldColumn.name)));
    hasToCalc |= oldColumns.any((oldColumn) => (!newColumns.any((newColumn) => newColumn.name == oldColumn.name)));

    if (!hasToCalc) {
      hasToCalc = newColumns.any((newColumn) {
        ColumnDefinition oldColumn = oldColumns.firstWhere((oldColumn) => oldColumn.name == newColumn.name);

        return oldColumn.width != newColumn.width;
      });
    }

    metaData = pMetaData;

    if (hasToCalc) {
      _recalculateTableSize(true);
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Action methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void _setValueEnd(dynamic pValue, int pRow, String pColumnName) {
    _selectRecord(pRow, pColumnName).then((_) {
      int colIndex = metaData?.columns.indexWhere((element) => element.name == pColumnName) ?? -1;

      if (colIndex >= 0 && pRow >= 0 && pRow < dataChunk.data.length && colIndex < dataChunk.data[pRow]!.length) {
        if (pValue is HashMap<String, dynamic>) {
          _setValues(pRow, pValue.keys.toList(), pValue.values.toList(), pColumnName);
        } else {
          _setValues(pRow, [pColumnName], [pValue], pColumnName);
        }
      }
    }).catchError(IUiService().handleAsyncError);
  }

  void _setValueChanged(dynamic pValue, int pRow, String pColumnName) {
    // Do nothing
  }

  /// Increments the page count and loads more data.
  void _loadMore() {
    if (!dataChunk.isAllFetched) {
      pageCount++;
      _subscribe();
    }
  }

  void _onCellTap(int pRowIndex, String pColumnName, ICellEditor pCellEditor) {
    if (pRowIndex == -1 || pColumnName.isEmpty) {
      _sortColumn(pColumnName);
    } else {
      _selectRecord(pRowIndex, pColumnName).then((_) {
        if (pCellEditor.allowedInTable && pCellEditor.allowedTableEdit && _isUpdateAllowed == true) {
          pCellEditor.click();
        }
      }).catchError(IUiService().handleAsyncError);
    }
  }

  void _onCellDoubleTap(int pRowIndex, String pColumnName, ICellEditor pCellEditor) {
    if (pRowIndex == -1 || pColumnName.isEmpty) {
      _sortColumn(pColumnName, true);
    }
  }

  _onLongPress(int pRowIndex, String pColumnName, ICellEditor pCellEditor, LongPressStartDetails pPressDetails) {
    List<PopupMenuEntry<TableContextMenuItem>> popupMenuEntries = <PopupMenuEntry<TableContextMenuItem>>[];

    if (_isInsertEnabled) {
      popupMenuEntries.add(_createContextMenuItem(FontAwesomeIcons.squarePlus, "New", TableContextMenuItem.INSERT));
    }

    int indexToDelete = pRowIndex >= 0 ? pRowIndex : selectedRow;
    if (_isDeleteEnabled && indexToDelete >= 0) {
      popupMenuEntries.add(_createContextMenuItem(FontAwesomeIcons.squareMinus, "Delete", TableContextMenuItem.DELETE));
    }

    if (pRowIndex == -1 && pColumnName.isNotEmpty && model.sortOnHeaderEnabled) {
      popupMenuEntries.add(_createContextMenuItem(FontAwesomeIcons.sort, "Sort", TableContextMenuItem.SORT));
    }

    if (pRowIndex >= 0 && pColumnName.isNotEmpty && _isUpdateAllowed) {
      popupMenuEntries.add(_createContextMenuItem(FontAwesomeIcons.penToSquare, "Edit", TableContextMenuItem.EDIT));
    }

    if (kDebugMode) {
      popupMenuEntries.add(_createContextMenuItem(FontAwesomeIcons.powerOff, "Offline", TableContextMenuItem.OFFLINE));
      popupMenuEntries
          .add(_createContextMenuItem(FontAwesomeIcons.circleArrowLeft, "Fetch", TableContextMenuItem.FETCH));
    }

    showMenu(
      position: RelativeRect.fromRect(
        pPressDetails.globalPosition & const Size(40, 40),
        Offset.zero & MediaQuery.of(context).size,
      ),
      context: context,
      items: popupMenuEntries,
    ).then((val) {
      if (val != null) {
        _menuItemPressed(
          val,
          pRowIndex,
          pColumnName,
          pCellEditor,
        );
      }
    });
  }

  void _menuItemPressed(TableContextMenuItem val, int pRowIndex, String pColumnName, ICellEditor pCellEditor) {
    IUiService()
        .saveAllEditors(
            pId: model.id,
            pFunction: () async {
              if (val == TableContextMenuItem.INSERT) {
                return [_createInsertCommand()];
              } else if (val == TableContextMenuItem.DELETE) {
                int indexToDelete = pRowIndex >= 0 ? pRowIndex : selectedRow;
                BaseCommand? command = _createDeleteCommand(indexToDelete);
                if (command != null) {
                  return [command];
                }
              } else if (val == TableContextMenuItem.OFFLINE) {
                _goOffline();
              } else if (val == TableContextMenuItem.FETCH) {
                _fetch();
              } else if (val == TableContextMenuItem.SORT) {
                _sortColumn(pColumnName);
              } else if (val == TableContextMenuItem.EDIT) {
                _editColumn(pRowIndex, pColumnName, pCellEditor);
              }
              return [];
            },
            pReason: "Table menu item pressed")
        .catchError(IUiService().handleAsyncError);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Selects the record.
  Future<void> _selectRecord(int pRowIndex, String pColumnName) async {
    Filter? filter = _createFilter(pRowIndex: pRowIndex);

    if (filter == null) {
      FlutterUI.logUI.w("Filter of table(${model.id}) null");
      return;
    }

    return ICommandService().sendCommand(SelectRecordCommand(
        dataProvider: model.dataProvider, selectedRecord: pRowIndex, reason: "Tapped", filter: filter));
  }

  /// Sends a [SetValuesCommand] for this row.
  void _setValues(int pRowIndex, List<String> pColumnNames, List<dynamic> pValues, String pEditorColumnName) {
    int rowIndex = pRowIndex;

    IUiService().sendCommand(
      SetValuesCommand(
        componentId: model.id,
        dataProvider: model.dataProvider,
        columnNames: pColumnNames,
        editorColumnName: pEditorColumnName,
        values: pValues,
        filter: _createFilter(pRowIndex: rowIndex),
        reason: "Values changed in table",
      ),
    );
  }

  /// Inserts a new record.
  void _insertRecord() {
    IUiService().sendCommand(_createInsertCommand());
  }

  InsertRecordCommand _createInsertCommand() {
    return InsertRecordCommand(dataProvider: model.dataProvider, reason: "Inserted");
  }

  /// Gets the value of a specified column
  dynamic _getValue({required String pColumnName, int? pRowIndex}) {
    int rowIndex = pRowIndex ?? selectedRow;
    if (rowIndex == -1) {
      return;
    }

    int colIndex = dataChunk.columnDefinitions.indexWhere((element) => element.name == pColumnName);

    if (colIndex == -1) {
      return;
    }

    return dataChunk.data[rowIndex]![colIndex];
  }

  /// Creates an identifying filter for this row.
  Filter? _createFilter({required int pRowIndex}) {
    int rowIndex = pRowIndex;
    if (metaData == null) {
      return null;
    }

    List<String> listColumnNames = [];
    List<dynamic> listValues = [];

    /* Old way of doing it.
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
    */

    if (metaData!.primaryKeyColumns.isNotEmpty) {
      listColumnNames.addAll(metaData!.primaryKeyColumns);
    } else {
      listColumnNames.addAll(metaData!.columns.map((e) => e.name));
    }

    for (String column in listColumnNames) {
      listValues.add(_getValue(pColumnName: column, pRowIndex: rowIndex));
    }

    return Filter(values: listValues, columnNames: listColumnNames);
  }

  PopupMenuItem<TableContextMenuItem> _createContextMenuItem(IconData icon, String text, TableContextMenuItem value) {
    return PopupMenuItem<TableContextMenuItem>(
      enabled: true,
      value: value,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 24,
            alignment: Alignment.center,
            child: FaIcon(
              icon,
              size: 20,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Text(
              FlutterUI.translate(
                text,
              ),
              style: model.createTextStyle(),
            ),
          ),
        ],
      ),
    );
  }

  /// Debug feature -> Takes one dataprovider offline
  void _goOffline() {
    BeamState state = context.currentBeamLocation.state as BeamState;
    String workscreenName = state.pathParameters['workScreenName']!;
    OfflineUtil.initOffline(workscreenName);
  }

  void _fetch() {
    IUiService()
        .sendCommand(FetchCommand(dataProvider: model.dataProvider, fromRow: 0, rowCount: -1, reason: "debug fetch"));
  }

  /// Creates a delete command for this row.
  DeleteRecordCommand? _createDeleteCommand(int pIndex) {
    Filter? filter = _createFilter(pRowIndex: pIndex);

    if (filter == null) {
      FlutterUI.logUI.w("Filter of table(${model.id}) null");
      return null;
    }
    return DeleteRecordCommand(
      dataProvider: model.dataProvider,
      selectedRow: pIndex,
      reason: "Swiped",
      filter: filter,
    );
  }

  void _sortColumn(String pColumnName, [bool pAdditive = false]) {
    if (!model.sortOnHeaderEnabled) {
      return;
    }

    SortDefinition? currentSortDefinition =
        dataChunk.sortDefinitions?.firstWhereOrNull((sortDef) => sortDef.columnName == pColumnName);

    dataChunk.sortDefinitions?.remove(currentSortDefinition);
    currentSortDefinition?.mode = currentSortDefinition.nextMode;
    currentSortDefinition ??= SortDefinition(columnName: pColumnName);

    List<SortDefinition> sortDefs = [currentSortDefinition];
    if (pAdditive && dataChunk.sortDefinitions != null) {
      sortDefs.addAll(dataChunk.sortDefinitions!);
    }

    IUiService().sendCommand(
      SortCommand(dataProvider: model.dataProvider, sortDefinitions: sortDefs, reason: "sorted"),
    );
  }

  void _editColumn(int pRowIndex, String pColumnName, ICellEditor pCellEditor) {
    _selectRecord(pRowIndex, pColumnName)
        .then((value) => pCellEditor.click())
        .catchError(IUiService().handleAsyncError);
  }

  void _onAction(int pRowIndex, String pColumnName, Function pAction) {
    _selectRecord(pRowIndex, pColumnName).then((value) => pAction.call()).catchError(IUiService().handleAsyncError);
  }
}

enum TableContextMenuItem { INSERT, DELETE, OFFLINE, EDIT, SORT, FETCH }
