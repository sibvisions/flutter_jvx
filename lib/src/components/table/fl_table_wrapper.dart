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

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import '../../../flutter_jvx.dart';
import '../../model/command/api/sort_command.dart';
import '../../model/command/ui/set_focus_command.dart';
import '../../model/component/editor/cell_editor/cell_editor_model.dart';
import '../../model/data/sort_definition.dart';
import '../../model/layout/layout_data.dart';
import '../../service/api/shared/fl_component_classname.dart';
import '../../util/column_list.dart';
import '../../util/jvx_logger.dart';
import '../../util/sort_list.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';
import '../editor/cell_editor/i_cell_editor.dart';
import 'fl_data_mixin.dart';

class FlTableWrapper extends BaseCompWrapperWidget<FlTableModel> {
  static const int DEFAULT_ITEM_COUNT_PER_PAGE = FlutterUI.readAheadLimit;

  const FlTableWrapper({super.key, required super.model});

  @override
  BaseCompWrapperState<FlComponentModel> createState() => _FlTableWrapperState();
}

class _FlTableWrapperState extends BaseCompWrapperState<FlTableModel> with FlDataMixin {
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

  /// The scroll controller for the table.
  late final ScrollController tableHorizontalController;

  /// The scroll controller for the headers if they are set to sticky.
  late final ScrollController headerHorizontalController;

  /// The scroll group to synchronize sticky header scrolling.
  final LinkedScrollControllerGroup linkedScrollGroup = LinkedScrollControllerGroup();

  /// The value notifier for a potential editing dialog.
  ValueNotifier<Map<String, dynamic>?> dialogValueNotifier = ValueNotifier<Map<String, dynamic>?>(null);

  /// The currently opened editing dialog
  Future? currentEditDialog;

  /// The last sort definition.
  SortList? lastSortDefinitions;

  /// The timer for double-tap check
  Timer? _timerTap;

  /// The column name of the last tap.
  String? lastTapColumnName;

  /// The currently selected column. null is none.
  String? selectedColumn;

  /// The current status of the table wrapper.
  int currentState = 0;

  /// How many "pages" of the table data have been loaded multiplied by: [FlTableWrapper.DEFAULT_ITEM_COUNT_PER_PAGE]
  int pageCount = 1;

  /// The last selected row. Used to calculate the current scroll position
  /// if the table has not yet been scrolled.
  int lastScrolledToIndex = -1;

  /// The row index of last tap.
  int? lastTapRowIndex;

  /// The size has to be calculated on the next data receiving
  bool _calcOnDataReceived = false;

  /// If the selection has to be cancelled.
  bool cancelSelect = false;

  /// If the last scrolled item got scrolled to the top edge or bottom edge.
  bool? scrolledIndexTopAligned;

  /// The known scroll notification.
  ScrollNotification? lastScrollNotification;

  /// If the table should show a floating insert button
  bool get showFloatingButton =>
      !model.hideFloatButton &&
      model.isEnabled &&
      !metaData.readOnly &&
      metaData.insertEnabled &&
      // Only shows the floating button if we are bigger than 100x150
      ((layoutData.layoutPosition?.height ?? 0.0) >= 150) &&
      ((layoutData.layoutPosition?.width ?? 0.0) >= 100);

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

    tableSize = TableSize();

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

    if (layoutData.hasPosition) {
      model.stickyHeaders = layoutData.layoutPosition!.height > (2 * tableSize!.rowHeight + tableSize!.tableHeaderHeight);
    }

    widget ??= FlTableWidget(
      model: model,
      chunkData: dataChunk,
      metaData: metaData,
      tableSize: tableSize!,
      selectedRowIndex: selectedRowTemporary ?? selectedRow,
      selectedColumn: selectedColumn,
      slideActionFactory: createSlideActions,
      headerHorizontalController: headerHorizontalController,
      tableHorizontalController: tableHorizontalController,
      initialScrollToSelected: lastSelectedRow != selectedRow,
      onEndEditing: setValueOnEndEditing,
      onValueChanged: _setValueChanged,
      onRefresh: refresh,
      onEndScroll: _loadMore,
      onScroll: (pScrollNotification) => lastScrollNotification = pScrollNotification,
      onLongPress: _onLongPress,
      onTap: _onTimedCellTap,
      onHeaderTap: _sortColumn,
      onHeaderDoubleTap: (pColumn) => _sortColumn(pColumn, true),
      onFloatingPress: showFloatingButton ? insertRecord : null,
    );

    lastSelectedRow = selectedRow;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return wrapWidget(child: widget);
  }

  @override
  void dispose() {
    _unsubscribe();

    tableHorizontalController.dispose();
    headerHorizontalController.dispose();
    super.dispose();
  }

  @override
  void receiveNewLayoutData(LayoutData pLayoutData) {
    bool newConstraint = pLayoutData.layoutPosition?.width != layoutData.layoutPosition?.width;
    super.receiveNewLayoutData(pLayoutData);

    if (newConstraint) {
      _recalculateTableSize();
    }
  }

  @override
  modelUpdated() {
    super.modelUpdated();

    if (model.lastChangedProperties.contains(ApiObjectProperty.dataProvider)) {
      columnsToShow = null;

      _subscribe();
    }

    bool namesChanged = model.lastChangedProperties.contains(ApiObjectProperty.columnNames);

    if (namesChanged) {
      columnsToShow = null;
    }

    if (namesChanged ||
        model.lastChangedProperties.contains(ApiObjectProperty.columnLabels) ||
        model.lastChangedProperties.contains(ApiObjectProperty.autoResize)) {
      _calcOnDataReceived = true;
      _recalculateTableSize();
    } else {
      setState(() {});
    }
  }

  @override
  Size calculateSize(BuildContext context) {
    return Size(
      tableSize!.sumCalculatedColumnWidth + (tableSize!.borderWidth * 2),
      tableSize!.tableHeaderHeight + (tableSize!.borderWidth * 2) + (tableSize!.rowHeight * dataChunk.data.length),
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Recalculates the size of the table.
  void _recalculateTableSize([bool pRecalculateWidth = true]) {
    if (pRecalculateWidth) {
      tableSize!.calculateTableSize(
        metaData: metaData,
        tableModel: model,
        dataChunk: dataChunk,
        availableWidth: layoutData.layoutPosition?.width,
        scaling: model.scaling,
      );
    }

    currentState |= CALCULATION_COMPLETE;
    sentLayoutData = false;

    setState(() {});
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Data methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Subscribes to the data service.
  void _subscribe() {
    IUiService().disposeDataSubscription(pSubscriber: this);

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
          onReload: _onDataProviderReload,
          onDataToDisplayMapChanged: _recalculateTableSize,
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
    IUiService().disposeDataSubscription(pSubscriber: this);

    currentState &= ~LOADED_META_DATA;
    currentState &= ~LOADED_DATA;
    currentState &= ~LOADED_SELECTED_RECORD;
  }

  int _onDataProviderReload() {
    int selectedRow = IDataService().getDataBook(model.dataProvider)?.selectedRow ?? -1;
    if (selectedRow >= 0) {
      pageCount = ((selectedRow + 1) / FlTableWrapper.DEFAULT_ITEM_COUNT_PER_PAGE).ceil();
    } else {
      pageCount = 1;
    }

    return FlTableWrapper.DEFAULT_ITEM_COUNT_PER_PAGE * pageCount;
  }

  /// Loads data from the server.
  void _receiveTableData(DataChunk pDataChunk) {
    bool recalculateWidth = (currentState & LOADED_DATA) != LOADED_DATA;
    currentState |= LOADED_DATA;

    if (!recalculateWidth) {
      recalculateWidth = !listEquals(pDataChunk.columnDefinitions.listNames, dataChunk.columnDefinitions.listNames);
    }

    bool changedDataCount = (dataChunk.data.length != pDataChunk.data.length);
    dataChunk = pDataChunk;

    if (isDataRow(selectedRow)) {
      Map<String, dynamic> valueMap = {};

      for (ColumnDefinition colDef in dataChunk.columnDefinitions) {
        valueMap[colDef.name] = dataChunk.data[selectedRow]![dataChunk.columnDefinitions.indexByName(colDef.name)];
      }

      dialogValueNotifier.value = valueMap;
    }

    if (recalculateWidth || _calcOnDataReceived || changedDataCount || dataChunk.fromStart) {

      _closeDialog();
      _recalculateTableSize(recalculateWidth || _calcOnDataReceived || dataChunk.fromStart);
      _calcOnDataReceived = false;
    } else {
      setState(() {});
    }
  }

  /// Receives which row is selected.
  void _receiveSelectedRecord(DataRecord? pRecord) {
    currentState |= LOADED_SELECTED_RECORD;

    var currentSelectedRow = selectedRow;

    if (pRecord != null) {
      selectedRow = pRecord.index;
      selectedColumn = pRecord.selectedColumn;
    } else {
      DataBook? dataBook = IDataService().getDataBook(model.dataProvider);
      if (dataBook != null) {
        selectedRow = dataBook.selectedRow;
        selectedColumn = dataBook.selectedColumn;
      } else {
        selectedRow = -1;
        selectedColumn = null;
      }
    }

    //possible that we tap faster than the selection happens. To avoid selection toggling
    //use this check
    if (selectedRow == selectedRowTemporary) {
      selectedRowTemporary = null;
    }

    // Close dialog to edit a row if current row was changed.
    if (currentSelectedRow != selectedRow) {
      _closeDialog();
    }

    // If have not fetched until the selected row index, fetch until the selected row page.
    // This is mostly not needed anymore as we already fetch on reload -1 and
    // [_onDataProviderReload] already updates the subscription. But we still keep it
    // as it is a safety net.
    if (selectedRow >= (pageCount * FlTableWrapper.DEFAULT_ITEM_COUNT_PER_PAGE)) {
      pageCount = ((selectedRow + 1) / FlTableWrapper.DEFAULT_ITEM_COUNT_PER_PAGE).ceil();
      _subscribe();
    }

    setState(() {});
  }

  /// Receives the meta data of the table.
  void _receiveMetaData(DalMetaData pMetaData) {
    bool hasToCalc = (currentState & LOADED_META_DATA) != LOADED_META_DATA;
    currentState |= LOADED_META_DATA;

    metaData = pMetaData;

    hasToCalc = metaData.changedProperties.contains(ApiObjectProperty.columns);

    if (!hasToCalc && (metaData.sortDefinitions != null || lastSortDefinitions != null)) {
      hasToCalc = metaData.sortDefinitions?.length != lastSortDefinitions?.length;

      if (!hasToCalc) {
        hasToCalc = metaData.sortDefinitions?.any((newSort) => !lastSortDefinitions!.any((oldSort) {
                  return oldSort.columnName == newSort.columnName && oldSort.mode == newSort.mode;
                })) ??
            false;

        hasToCalc |= lastSortDefinitions?.any((oldSort) => !metaData.sortDefinitions!.any((newSort) {
                  return oldSort.columnName == newSort.columnName && oldSort.mode == newSort.mode;
                })) ??
            false;
      }
    }

    lastSortDefinitions = metaData.sortDefinitions;

    if (hasToCalc) {
      _calcOnDataReceived = true;
      _recalculateTableSize();
    } else {
      setState(() {});
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Action methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

  void _onTimedCellTap(int pRowIndex, String pColumnName, ICellEditor pCellEditor) {
    if (pRowIndex == -1) {
      if (pColumnName.isNotEmpty) {
        // Header was pressed
        _sortColumn(pColumnName);
      }

      return;
    }

    if (FlutterUI.logUI.cl(Lvl.d)) {
      FlutterUI.logUI.d("Select row temporary: $pRowIndex");
    }

    bool doubleTap = false;

    if (lastTapRowIndex != pRowIndex || lastTapColumnName != pColumnName) {
      _timerTap?.cancel();
      _timerTap = null;
    }
    else {
      if (_timerTap?.isActive == true) {
        _timerTap?.cancel();
        _timerTap = null;

        _onDoubleCellTap(pRowIndex, pColumnName, pCellEditor);

        //no single tap after double tap
        doubleTap = true;
      }
      else {
        _timerTap = null;
      }
    }

    if (!doubleTap) {
      _timerTap = Timer(
          const Duration(milliseconds: 300),
              () {
            _onCellTap(pRowIndex, pColumnName, pCellEditor);
          }
      );
    }

    selectedRowTemporary = pRowIndex;

    lastTapRowIndex = pRowIndex;
    lastTapColumnName = pColumnName;

    setState(() {});
  }

  void _onCellTap(int pRowIndex, String pColumnName, ICellEditor pCellEditor) {
    if (FlutterUI.logUI.cl(Lvl.d)) {
      FlutterUI.logUI.d("Table cell tapped: $pRowIndex, $pColumnName");
    }

    selectRecord(
      pRowIndex,
      columnName: pColumnName,
      force: true,
      afterSelectCommand: () {

        if (FlutterUI.logUI.cl(Lvl.d)) {
          FlutterUI.logUI.d("Selected row: $pRowIndex");
        }

        if (IStorageService().isVisibleInUI(model.id) &&
            !pCellEditor.allowedInTable &&
            isCellEditable(pRowIndex, pColumnName) &&
            pCellEditor.model.preferredEditorMode == ICellEditorModel.SINGLE_CLICK) {
          _showDialog(
            rowIndex: pRowIndex,
            columnDefinitions: ColumnList.fromElement(pCellEditor.columnDefinition!),
            values: {pCellEditor.columnDefinition!.name: dataChunk.getValue(pColumnName, pRowIndex)},
            dataRow: dataChunk.data[pRowIndex],
            onEndEditing: setValueOnEndEditing,
            newValueNotifier: dialogValueNotifier,
          );
        }

        return [];
      }
    );
  }

  void _onDoubleCellTap(int pRowIndex, String pColumnName, ICellEditor pCellEditor) {
    if (FlutterUI.logUI.cl(Lvl.d)) {
      FlutterUI.logUI.d("Table cell double tapped: $pRowIndex, $pColumnName");
    }

    selectRecord(
      pRowIndex,
      columnName: pColumnName,
      force: true,
      afterSelectCommand: () {
        if (FlutterUI.logUI.cl(Lvl.d)) {
          FlutterUI.logUI.d("Selected row: $pRowIndex");
        }

        if (IStorageService().isVisibleInUI(model.id) &&
            !pCellEditor.allowedInTable &&
            isCellEditable(pRowIndex, pColumnName) &&
            pCellEditor.model.preferredEditorMode == ICellEditorModel.DOUBLE_CLICK) {
          _showDialog(
            rowIndex: pRowIndex,
            columnDefinitions: ColumnList.fromElement(pCellEditor.columnDefinition!),
            values: {pCellEditor.columnDefinition!.name: dataChunk.getValue(pColumnName, pRowIndex)},
            dataRow: dataChunk.data[pRowIndex],
            onEndEditing: setValueOnEndEditing,
            newValueNotifier: dialogValueNotifier,
          );
        }

        return [];
      }
    );
  }

  _onLongPress(int pRowIndex, String pColumnName, ICellEditor pCellEditor, Offset pGlobalPosition) {
    List<PopupMenuEntry<DataContextMenuItemType>> popupMenuEntries = <PopupMenuEntry<DataContextMenuItemType>>[];

    int separator = 0;

    if (pRowIndex == -1 && kDebugMode) {
      popupMenuEntries.add(createContextMenuItem(Icons.cloud_off, "Offline", DataContextMenuItemType.OFFLINE));
      separator++;
    }

    if (pRowIndex == -1 && pColumnName.isNotEmpty && model.sortOnHeaderEnabled) {
      popupMenuEntries.add(createContextMenuItem(FontAwesomeIcons.sort, "Sort", DataContextMenuItemType.SORT));
      separator++;
    }

    if (metaData.insertEnabled && !metaData.readOnly) {
      popupMenuEntries.add(createContextMenuItem(FontAwesomeIcons.squarePlus, "New", DataContextMenuItemType.INSERT));
    }

    if (isRowDeletable(pRowIndex)) {
      popupMenuEntries.add(createContextMenuItem(FontAwesomeIcons.squareMinus, "Delete", DataContextMenuItemType.DELETE));
    }

    if (isAnyCellInRowEditable(pRowIndex)) {
      popupMenuEntries.add(createContextMenuItem(FontAwesomeIcons.penToSquare, "Edit", DataContextMenuItemType.EDIT));
    }

    if (separator > 0 && popupMenuEntries.length > separator) {
      popupMenuEntries.insert(separator, const PopupMenuDivider(height: 3));
    }

    if (popupMenuEntries.isNotEmpty) {
      showPopupMenu(context, pGlobalPosition, popupMenuEntries).then((type) {
        if (type != null) {
          _menuItemPressed(
            type,
            pRowIndex,
            pColumnName,
            pCellEditor,
          );
        }
      });
    }
  }

  void _menuItemPressed(DataContextMenuItemType val, int pRowIndex, String pColumnName, ICellEditor pCellEditor) {
    IUiService().saveAllEditors(
      pId: model.id,
      pReason: "Table menu item pressed",
    ).then((success) {
      if (!success) {
        return;
      }

      List<BaseCommand> commands = [];

      if (val == DataContextMenuItemType.OFFLINE) {
        if (mounted) {
          debugGoOffline(context);
        }
      }
      else if (val == DataContextMenuItemType.SORT) {
        BaseCommand? command = _createSortColumnCommand(pColumnName);

        if (command != null) {
          commands.add(command);
        }
      }
      else if (val == DataContextMenuItemType.INSERT) {
        commands.add(createInsertCommand());
      } else if (val == DataContextMenuItemType.DELETE) {
        BaseCommand? command = createDeleteCommand(pRowIndex >= 0 ? pRowIndex : selectedRow);

        if (command != null) {
          commands.add(command);
        }
      }
      else if (val == DataContextMenuItemType.EDIT) {
        _editRow(pRowIndex);
      }
      else if (val == DataContextMenuItemType.RELOAD) {
        unawaited(refresh());
      }

      if (commands.isNotEmpty) {
        commands.insert(0, SetFocusCommand(componentId: model.id, focus: true, reason: "Popup command Focus"));

        ICommandService().sendCommands(commands);
      }
    });
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  BaseCommand? _createSortColumnCommand(String pColumnName, [bool pAdditive = false]) {
    if (!model.sortOnHeaderEnabled) {
      return null;
    }
    ColumnDefinition? colDef = metaData.columnDefinitions.byName(pColumnName);

    if (colDef == null || !colDef.sortable) {
      return null;
    }

    SortDefinition? currentSortDefinition = metaData.sortDefinitions?.byName(pColumnName);
    bool exists = currentSortDefinition != null;

    currentSortDefinition?.mode = currentSortDefinition.nextMode;
    currentSortDefinition ??= SortDefinition(columnName: pColumnName);

    SortList sort;
    if (pAdditive && metaData.sortDefinitions != null) {
      sort = SortList([
        ...metaData.sortDefinitions ?? {},
        if (!exists) currentSortDefinition,
      ]);
    } else {
      sort = SortList.fromElement(currentSortDefinition);
    }

    return SortCommand(
        dataProvider: model.dataProvider, sortDefinitions: sort, reason: "sorted", columnName: pColumnName);
  }

  void _sortColumn(String pColumnName, [bool pAdditive = false]) {
    BaseCommand? sortCommand = _createSortColumnCommand(pColumnName, pAdditive);
    if (sortCommand == null) {
      return;
    }

    IUiService().saveAllEditors(
      pReason: "Sort of ${model.dataProvider}",
      pId: model.id,
    ).then((success) {
      if (!success) {
        return;
      }

      ICommandService().sendCommands([
        SetFocusCommand(componentId: model.id, focus: true, reason: "Sort of ${model.dataProvider}"),
        sortCommand,
      ]);
    });
  }

  void _editRow(int pRowIndex) {
    selectRecord(
      pRowIndex,
      afterSelectCommand: () {
        selectedRowTemporary = null;

        if (IStorageService().isVisibleInUI(model.id) && isAnyCellInRowEditable(pRowIndex)) {
          var editColumns = getEditableColumns(pRowIndex);

          _showDialog(
            rowIndex: pRowIndex,
            columnDefinitions: editColumns.columns,
            values: editColumns.values,
            onEndEditing: setValueOnEndEditing,
            newValueNotifier: dialogValueNotifier,
          );
        }
        return [];
      },
    );
  }

  List<SlidableAction> createSlideActions(BuildContext context, int row) {
    List<SlidableAction> slideActions = [];

    bool isLight = JVxColors.isLightTheme(context);

    if (isAnyCellInRowEditable(row)) {
      slideActions.add(
        SlidableAction(
          onPressed: (context) {
            _editRow(row);
          },
          autoClose: true,
          backgroundColor: isLight ? Colors.green : const Color(0xFF2c662f),
          foregroundColor: isLight ? Colors.white : Theme
              .of(context)
              .textTheme
              .labelSmall!
              .color,
          label: FlutterUI.translate("Edit"),
          icon: FontAwesomeIcons.penToSquare,
          padding: const EdgeInsets.only(left: 8, right: 8),
        ),
      );
    }

    if (isRowDeletable(row)) {
      slideActions.add(
        SlidableAction(
          onPressed: (context) {
            String? status = dataChunk.getRecordStatusRaw(row);

            //sometimes this event is triggered more than once, so don't delete again
            if (status != null && !status.contains("SLIDE_DELETE")) {
              if (status.isNotEmpty) {
                dataChunk.setStatusRaw(row, "$status,SLIDE_DELETE");
              }
              else {
                dataChunk.setStatusRaw(row, "SLIDE_DELETE");
              }

              BaseCommand? deleteCommand = createDeleteCommand(row);

              if (deleteCommand != null) {
                ICommandService().sendCommand(deleteCommand);
              }
            }
          },
          autoClose: true,
          backgroundColor: isLight ? Colors.red : const Color(0xFF932821),
          foregroundColor: isLight ? Colors.white : Theme
              .of(context)
              .textTheme
              .labelSmall!
              .color,
          label: FlutterUI.translate("Delete"),
          icon: FontAwesomeIcons.trash,
          padding: const EdgeInsets.only(left: 8, right: 8),
        ),
      );
    }

    return slideActions;
  }

  void _showDialog({
    required int rowIndex,
    required ColumnList columnDefinitions,
    required Map<String, dynamic> values,
    required void Function(dynamic, int, String) onEndEditing,
    required ValueNotifier<Map<String, dynamic>?> newValueNotifier,
    List<dynamic>? dataRow,
  }) {
    if (columnDefinitions.isEmpty) {
      _closeDialog();
    }
    else if (currentEditDialog == null) {
      if (columnDefinitions.length == 1 &&
          (columnDefinitions.first.cellEditorJson[ApiObjectProperty.className] ==
             FlCellEditorClassname.LINKED_CELL_EDITOR ||
           columnDefinitions.first.cellEditorJson[ApiObjectProperty.className] ==
             FlCellEditorClassname.DATE_CELL_EDITOR)) {

        ColumnDefinition colDef = columnDefinitions.first;

        ICellEditor cellEditor = ICellEditor.getCellEditor(
          cellEditorJson: columnDefinitions.first.cellEditorJson,
          name: model.name,
          dataProvider: model.dataProvider,
          columnName: colDef.name,
          columnDefinition: colDef,
          isInTable: true,
          onEndEditing: (value) => onEndEditing(value, rowIndex, colDef.name)
        );

        if (cellEditor is FlLinkedCellEditor) {
          cellEditor.setValue((values[colDef.name], dataRow));

          currentEditDialog = cellEditor.openLinkedCellPicker();
        } else if (cellEditor is FlDateCellEditor){
          cellEditor.setValue(values[colDef.name]);

          currentEditDialog = cellEditor.openDatePicker();
        }

        cellEditor.dispose();
      } else if (columnDefinitions.isNotEmpty) {
        currentEditDialog = IUiService().openDialog(
          pBuilder: (context) =>
              FlTableEditDialog(
                rowIndex: rowIndex,
                model: model,
                columnDefinitions: columnDefinitions,
                values: values,
                valuesRow: dataChunk.getValuesAsMap(rowIndex),
                onEndEditing: onEndEditing,
                newValueNotifier: newValueNotifier,
              ),
        );
      }

      if (currentEditDialog != null) {
        currentEditDialog!.whenComplete(() => currentEditDialog = null);
      }
    }
  }

  void _closeDialog() {
    if (currentEditDialog != null) {
      currentEditDialog = null;
      Navigator.pop(context);
    }
  }

}
