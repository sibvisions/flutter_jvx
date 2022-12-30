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

import 'package:beamer/beamer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../flutter_ui.dart';
import '../../model/command/api/delete_record_command.dart';
import '../../model/command/api/insert_record_command.dart';
import '../../model/command/api/select_record_command.dart';
import '../../model/command/api/set_values_command.dart';
import '../../model/command/base_command.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/component/table/fl_table_model.dart';
import '../../model/data/column_definition.dart';
import '../../model/data/subscriptions/data_chunk.dart';
import '../../model/data/subscriptions/data_record.dart';
import '../../model/data/subscriptions/data_subscription.dart';
import '../../model/layout/layout_data.dart';
import '../../model/request/filter.dart';
import '../../model/response/dal_meta_data_response.dart';
import '../../service/api/shared/api_object_property.dart';
import '../../service/command/i_command_service.dart';
import '../../service/ui/i_ui_service.dart';
import '../../util/offline_util.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';
import '../editor/cell_editor/i_cell_editor.dart';
import 'fl_table_widget.dart';
import 'table_size.dart';

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

    tableSize = TableSize.direct(tableModel: model, dataChunk: chunkData);

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
      chunkData: chunkData,
      tableSize: tableSize,
      selectedRowIndex: selectedRow,
      onEndEditing: _setValueEnd,
      onValueChanged: _setValueChanged,
      onEndScroll: _loadMore,
      onLongPress: showContextMenu,
      onTap: _onCellTap,
      onHeaderTap: _onCellTap,
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
  void _receiveTableData(DataChunk pChunkData) {
    currentState |= LOADED_DATA;

    List<String> newColumns = pChunkData.columnDefinitions.map((e) => e.name).toList();
    List<String> oldColumns = chunkData.columnDefinitions.map((e) => e.name).toList();
    bool hasToCalc = newColumns.any((element) => (!oldColumns.contains(element))) ||
        oldColumns.any((element) => (!newColumns.contains(element)));

    if (pChunkData.update) {
      for (int index in pChunkData.data.keys) {
        chunkData.data[index] = pChunkData.data[index]!;
      }
    } else {
      chunkData = pChunkData;
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
    _selectRecord(pRow).then((_) {
      int colIndex = metaData?.columns.indexWhere((element) => element.name == pColumnName) ?? -1;

      if (colIndex >= 0 && pRow >= 0 && pRow < chunkData.data.length && colIndex < chunkData.data[pRow]!.length) {
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
    if (!chunkData.isAllFetched) {
      pageCount++;
      _subscribe();
    }
  }

  void _onCellTap(int pRowIndex, String pColumnName, ICellEditor pCellEditor) {
    if (pRowIndex == -1 || pColumnName.isEmpty) {
      _sortColumn();
    } else {
      _selectRecord(pRowIndex).then((_) {
        if (pCellEditor.allowedInTable && pCellEditor.allowedTableEdit && _isUpdateAllowed == true) {
          pCellEditor.click();
        }
      }).catchError(IUiService().handleAsyncError);
    }
  }

  showContextMenu(int pRowIndex, String pColumnName, ICellEditor pCellEditor, LongPressStartDetails pPressDetails) {
    List<PopupMenuEntry<ContextMenuCommand>> popupMenuEntries = <PopupMenuEntry<ContextMenuCommand>>[];

    if (_isInsertEnabled) {
      popupMenuEntries.add(_createContextMenuItem(FontAwesomeIcons.squarePlus, "New", ContextMenuCommand.INSERT));
    }

    int indexToDelete = pRowIndex >= 0 ? pRowIndex : selectedRow;
    if (_isDeleteEnabled && indexToDelete >= 0) {
      popupMenuEntries.add(_createContextMenuItem(FontAwesomeIcons.squareMinus, "Delete", ContextMenuCommand.DELETE));
    }

    if (pRowIndex == -1 && pColumnName.isNotEmpty) {
      popupMenuEntries.add(_createContextMenuItem(FontAwesomeIcons.sort, "Sort", ContextMenuCommand.SORT));
    }

    if (pRowIndex >= 0 && pColumnName.isNotEmpty && _isUpdateAllowed) {
      popupMenuEntries.add(_createContextMenuItem(FontAwesomeIcons.penToSquare, "Edit", ContextMenuCommand.EDIT));
    }

    if (kDebugMode) {
      popupMenuEntries.add(_createContextMenuItem(FontAwesomeIcons.powerOff, "Offline", ContextMenuCommand.OFFLINE));
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
        IUiService()
            .saveAllEditors(
                pId: model.id,
                pFunction: () async {
                  if (val == ContextMenuCommand.INSERT) {
                    return [_createInsertCommand()];
                  } else if (val == ContextMenuCommand.DELETE) {
                    BaseCommand? command = _createDeleteCommand(indexToDelete);
                    if (command != null) {
                      return [command];
                    }
                  } else if (val == ContextMenuCommand.OFFLINE) {
                    _goOffline();
                  } else if (val == ContextMenuCommand.SORT) {
                    _sortColumn();
                  } else if (val == ContextMenuCommand.EDIT) {
                    _editColumn();
                  }
                  return [];
                },
                pReason: "Table menu item pressed")
            .catchError(IUiService().handleAsyncError);
      }
    });
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Selects the record.
  Future<void> _selectRecord(int pRowIndex) async {
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

    int colIndex = chunkData.columnDefinitions.indexWhere((element) => element.name == pColumnName);

    if (colIndex == -1) {
      return;
    }

    return chunkData.data[rowIndex]![colIndex];
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

  PopupMenuItem<ContextMenuCommand> _createContextMenuItem(IconData icon, String text, ContextMenuCommand value) {
    return PopupMenuItem<ContextMenuCommand>(
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

  void _sortColumn() {}

  void _editColumn() {}

  void _onAction(int pRowIndex, String pColumnName, Function pAction) {
    _selectRecord(pRowIndex).then((value) => pAction.call()).catchError(IUiService().handleAsyncError);
  }
}

enum ContextMenuCommand { INSERT, DELETE, OFFLINE, EDIT, SORT }
