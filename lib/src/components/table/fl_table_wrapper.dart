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
import 'dart:collection';

import 'package:beamer/beamer.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../flutter_ui.dart';
import '../../model/command/api/delete_record_command.dart';
import '../../model/command/api/fetch_command.dart';
import '../../model/command/api/insert_record_command.dart';
import '../../model/command/api/select_record_command.dart';
import '../../model/command/api/set_values_command.dart';
import '../../model/command/api/sort_command.dart';
import '../../model/command/base_command.dart';
import '../../model/command/ui/function_command.dart';
import '../../model/command/ui/set_focus_command.dart';
import '../../model/component/editor/cell_editor/cell_editor_model.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/data/column_definition.dart';
import '../../model/data/data_book.dart';
import '../../model/data/sort_definition.dart';
import '../../model/data/subscriptions/data_chunk.dart';
import '../../model/data/subscriptions/data_record.dart';
import '../../model/data/subscriptions/data_subscription.dart';
import '../../model/layout/layout_data.dart';
import '../../model/request/filter.dart';
import '../../routing/locations/main_location.dart';
import '../../service/api/shared/api_object_property.dart';
import '../../service/api/shared/fl_component_classname.dart';
import '../../service/command/i_command_service.dart';
import '../../service/data/i_data_service.dart';
import '../../service/storage/i_storage_service.dart';
import '../../service/ui/i_ui_service.dart';
import '../../util/offline_util.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';
import '../editor/cell_editor/date/fl_date_cell_editor.dart';
import '../editor/cell_editor/i_cell_editor.dart';
import '../editor/cell_editor/linked/fl_linked_cell_editor.dart';
import 'fl_table_edit_dialog.dart';
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

  /// The currently selected column. null is none.
  String? selectedColumn;

  /// The meta data of the table.
  DalMetaData metaData = DalMetaData("");

  /// The data of the table.
  DataChunk dataChunk = DataChunk.empty();

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

  /// The value notifier for a potential editing dialog.
  ValueNotifier<Map<String, dynamic>?> dialogValueNotifier = ValueNotifier<Map<String, dynamic>?>(null);

  /// The currently opened editing dialog
  Future? currentEditDialog;

  /// The last sort definition.
  List<SortDefinition>? lastSortDefinitions;

  /// The size has to be calculated on the next data receiving
  bool _calcOnDataReceived = false;

  /// If the selection has to be cancelled.
  bool cancelSelect = false;

  /// The last selected row. Used to calculate the current scroll position
  /// if the table has not yet been scrolled.
  int lastScrolledToIndex = -1;

  /// If the last scrolled item got scrolled to the top edge or bottom edge.
  bool? scrolledIndexTopAligned;

  /// The known scroll notification.
  ScrollNotification? lastScrollNotification;

  /// The last used selection tap future
  Future<bool>? lastSelectionTapFuture;

  /// The last single tap timer.
  Timer? lastSingleTapTimer;

  /// If the menu is currently open
  bool menuOpen = false;

  /// The last row tapped
  int? lastTappedRow;

  /// The last column tapped
  String? lastTappedColumn;

  /// If the table should show a floating insert button
  bool get showFloatingButton =>
      model.showFloatButton &&
      model.isEnabled &&
      !metaData.readOnly &&
      metaData.insertEnabled &&
      // Only shows the floating button if we are bigger than 150x150
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
      model.stickyHeaders = layoutData.layoutPosition!.height > (2 * tableSize.rowHeight + tableSize.tableHeaderHeight);
    }

    widget ??= FlTableWidget(
      headerHorizontalController: headerHorizontalController,
      itemScrollController: itemScrollController,
      tableHorizontalController: tableHorizontalController,
      model: model,
      chunkData: dataChunk,
      metaData: metaData,
      tableSize: tableSize,
      selectedRowIndex: selectedRow,
      selectedColumn: selectedColumn,
      onEndEditing: _setValueEnd,
      onValueChanged: _setValueChanged,
      onRefresh: _refresh,
      onEndScroll: _loadMore,
      onScroll: (pScrollNotification) => lastScrollNotification = pScrollNotification,
      onLongPress: _onLongPress,
      onTap: _onCellTap,
      onHeaderTap: _sortColumn,
      onHeaderDoubleTap: (pColumn) => _sortColumn(pColumn, true),
      slideActionFactory: createSlideActions,
      showFloatingButton: showFloatingButton,
      floatingOnPress: _insertRecord,
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return wrapWidget(child: widget);
  }

  @override
  void postFrameCallback(BuildContext context) {
    if (!mounted) {
      return;
    }

    _scrollToSelected();

    super.postFrameCallback(context);
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
      _subscribe();
    }

    if (model.lastChangedProperties.contains(ApiObjectProperty.columnNames) ||
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
      tableSize.sumCalculatedColumnWidth + (tableSize.borderWidth * 2),
      tableSize.tableHeaderHeight + (tableSize.borderWidth * 2) + (tableSize.rowHeight * dataChunk.data.length),
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Recalculates the size of the table.
  void _recalculateTableSize([bool pRecalculateWidth = true]) {
    if (pRecalculateWidth) {
      tableSize.calculateTableSize(
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
    IUiService().disposeDataSubscription(pSubscriber: this, pDataProvider: model.dataProvider);

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
      List<String> newColumns = pDataChunk.columnDefinitions.map((e) => e.name).toList();
      List<String> oldColumns = dataChunk.columnDefinitions.map((e) => e.name).toList();
      recalculateWidth = newColumns.any((element) => (!oldColumns.contains(element))) ||
          oldColumns.any((element) => (!newColumns.contains(element)));
    }

    bool changedDataCount = (dataChunk.data.length != pDataChunk.data.length);
    dataChunk = pDataChunk;

    if (selectedRow >= 0 && selectedRow < dataChunk.data.length) {
      Map<String, dynamic> valueMap = {};

      for (ColumnDefinition colDef in dataChunk.columnDefinitions) {
        valueMap[colDef.name] = dataChunk.data[selectedRow]![dataChunk.columnDefinitionIndex(colDef.name)];
      }

      dialogValueNotifier.value = valueMap;
    }

    if (recalculateWidth || _calcOnDataReceived || changedDataCount) {
      _closeDialog();
      _recalculateTableSize(recalculateWidth || _calcOnDataReceived);
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

  void _setValueEnd(dynamic pValue, int pRow, String pColumnName) {
    _selectRecord(
      pRow,
      pColumnName,
      pAfterSelect: () {
        int colIndex = metaData.columnDefinitions.indexWhere((element) => element.name == pColumnName);

        if (colIndex >= 0 && pRow >= 0 && pRow < dataChunk.data.length && colIndex < dataChunk.data[pRow]!.length) {
          if (pValue is HashMap<String, dynamic>) {
            if (pValue.keys.none((columnName) => !_isCellEditable(pRow, columnName))) {
              return [_setValues(pRow, pValue.keys.toList(), pValue.values.toList(), pColumnName)];
            }
          } else {
            if (_isCellEditable(pRow, pColumnName)) {
              return [
                _setValues(pRow, [pColumnName], [pValue], pColumnName)
              ];
            }
          }
        }

        return [];
      },
    );
  }

  void _setValueChanged(dynamic pValue, int pRow, String pColumnName) {
    // Do nothing
  }

  /// Refreshes this data provider
  Future<void> _refresh() {
    IUiService().notifySubscriptionsOfReload(pDataprovider: model.dataProvider);

    return ICommandService().sendCommand(
      FetchCommand(
        fromRow: 0,
        reload: true,
        rowCount: IUiService().getSubscriptionRowcount(pDataProvider: model.dataProvider),
        dataProvider: model.dataProvider,
        reason: "Table refreshed",
      ),
    );
  }

  /// Increments the page count and loads more data.
  void _loadMore() {
    if (!dataChunk.isAllFetched) {
      pageCount++;
      _subscribe();
    }
  }

  void _onCellTap(int pRowIndex, String pColumnName, ICellEditor pCellEditor) {
    if (pColumnName.isEmpty) {
      return;
    }

    if (pRowIndex == -1) {
      // Header was pressed
      _sortColumn(pColumnName);
      return;
    }

    FlutterUI.logUI.d("Table cell tapped: $pRowIndex, $pColumnName");
    FlutterUI.logUI.d("Active last single tap timer: ${lastSingleTapTimer?.isActive}");
    if (lastTappedColumn == pColumnName && lastTappedRow == pRowIndex && lastSingleTapTimer?.isActive == true) {
      FlutterUI.logUI.d("Tap type: double");
      lastTappedColumn = null;
      lastTappedRow = null;
      lastSingleTapTimer?.cancel();
      lastSelectionTapFuture?.then((value) {
        FlutterUI.logUI.d("Selecting was: $value");
        if (value) {
          FlutterUI.logUI.d("Double tap action");
          _onDoubleTap(pRowIndex, pColumnName, pCellEditor);
        }
      });
    } else {
      FlutterUI.logUI.d("Tap type: single");
      lastTappedColumn = pColumnName;
      lastTappedRow = pRowIndex;
      lastSingleTapTimer?.cancel();
      lastSelectionTapFuture = _selectRecord(pRowIndex, pColumnName);
      lastSingleTapTimer = Timer(const Duration(milliseconds: 300), () {
        lastSelectionTapFuture?.then((value) {
          FlutterUI.logUI.d("Selecting was: $value");
          if (value) {
            FlutterUI.logUI.d("Single tap action");
            _onSingleTap(pRowIndex, pColumnName, pCellEditor);
          }
        });
      });
    }
  }

  Future<void> _onSingleTap(int pRowIndex, String pColumnName, ICellEditor pCellEditor) async {
    if (IStorageService().isVisibleInUI(model.id)) {
      if (!pCellEditor.allowedInTable &&
          _isCellEditable(pRowIndex, pColumnName) &&
          pCellEditor.model.preferredEditorMode == ICellEditorModel.SINGLE_CLICK) {
        _showDialog(
          rowIndex: pRowIndex,
          columnDefinitions: [pCellEditor.columnDefinition!],
          values: {pCellEditor.columnDefinition!.name: dataChunk.getValue(pColumnName, pRowIndex)},
          dataRow: dataChunk.data[pRowIndex],
          onEndEditing: _setValueEnd,
          newValueNotifier: dialogValueNotifier,
        );
      }
    }
  }

  Future<void> _onDoubleTap(int pRowIndex, String pColumnName, ICellEditor pCellEditor) async {
    if (IStorageService().isVisibleInUI(model.id)) {
      if (!pCellEditor.allowedInTable &&
          _isCellEditable(pRowIndex, pColumnName) &&
          pCellEditor.model.preferredEditorMode == ICellEditorModel.DOUBLE_CLICK) {
        _showDialog(
          rowIndex: pRowIndex,
          columnDefinitions: [pCellEditor.columnDefinition!],
          values: {pCellEditor.columnDefinition!.name: dataChunk.getValue(pColumnName, pRowIndex)},
          dataRow: dataChunk.data[pRowIndex],
          onEndEditing: _setValueEnd,
          newValueNotifier: dialogValueNotifier,
        );
      }
    }
  }

  _onLongPress(int pRowIndex, String pColumnName, ICellEditor pCellEditor, Offset pGlobalPosition) {
    List<PopupMenuEntry<TableContextMenuItem>> popupMenuEntries = <PopupMenuEntry<TableContextMenuItem>>[];

    if (metaData.insertEnabled && !metaData.readOnly) {
      popupMenuEntries.add(_createContextMenuItem(FontAwesomeIcons.squarePlus, "New", TableContextMenuItem.INSERT));
    }

    if (_isRowDeletable(pRowIndex)) {
      popupMenuEntries.add(_createContextMenuItem(FontAwesomeIcons.squareMinus, "Delete", TableContextMenuItem.DELETE));
    }

    if (pRowIndex == -1 && pColumnName.isNotEmpty && model.sortOnHeaderEnabled) {
      popupMenuEntries.add(_createContextMenuItem(FontAwesomeIcons.sort, "Sort", TableContextMenuItem.SORT));
    }

    if (_isAnyCellInRowEditable(pRowIndex)) {
      popupMenuEntries.add(_createContextMenuItem(FontAwesomeIcons.penToSquare, "Edit", TableContextMenuItem.EDIT));
    }

    if (popupMenuEntries.isNotEmpty) {
      menuOpen = true;
      showMenu(
        position: RelativeRect.fromSize(
          pGlobalPosition & const Size(40, 40),
          MediaQuery.sizeOf(context),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
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
      }).whenComplete(() => menuOpen = false);
    }
  }

  void _menuItemPressed(TableContextMenuItem val, int pRowIndex, String pColumnName, ICellEditor pCellEditor) {
    IUiService()
        .saveAllEditors(
      pId: model.id,
      pReason: "Table menu item pressed",
    )
        .then((success) {
      if (!success) {
        return;
      }
      List<BaseCommand> commands = [];

      if (val == TableContextMenuItem.INSERT) {
        commands.add(_createInsertCommand());
      } else if (val == TableContextMenuItem.DELETE) {
        int indexToDelete = pRowIndex >= 0 ? pRowIndex : selectedRow;
        BaseCommand? command = _createDeleteCommand(indexToDelete);
        if (command != null) {
          commands.add(command);
        }
      } else if (val == TableContextMenuItem.OFFLINE) {
        _debugGoOffline();
      } else if (val == TableContextMenuItem.FETCH) {
        unawaited(_refresh());
      } else if (val == TableContextMenuItem.SORT) {
        BaseCommand? command = _createSortColumnCommand(pColumnName);
        if (command != null) {
          commands.add(command);
        }
      } else if (val == TableContextMenuItem.EDIT) {
        _editRow(pRowIndex);
      }
      if (commands.isNotEmpty) {
        commands.insert(0, SetFocusCommand(componentId: model.id, focus: true, reason: "Value edit Focus"));
      }

      ICommandService().sendCommands(commands);
    });
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Scrolls the table to the selected row if it is not visible.
  /// Can only be called in the post frame callback as the scroll controller
  /// otherwise has not yet been updated with the most recent items.
  void _scrollToSelected() {
    if (lastScrolledToIndex == selectedRow) {
      return;
    }
    bool headersInTable = !model.stickyHeaders && model.tableHeaderVisible;

    // Only scroll if current selected is not visible
    if (selectedRow >= 0 && selectedRow < dataChunk.data.length && itemScrollController.isAttached) {
      lastScrolledToIndex = selectedRow;
      int indexToScrollTo = selectedRow;
      if (headersInTable) {
        indexToScrollTo++;
      }

      double itemTop = indexToScrollTo * tableSize.rowHeight;
      double itemBottom = itemTop + tableSize.rowHeight;

      double topViewCutOff;
      double bottomViewCutOff;
      double heightOfView;

      if (lastScrollNotification != null) {
        topViewCutOff = lastScrollNotification!.metrics.extentBefore;
        heightOfView = lastScrollNotification!.metrics.viewportDimension;
        bottomViewCutOff = topViewCutOff + heightOfView;
      } else if (layoutData.layoutPosition == null) {
        // Needs a position to calculate.
        // Probably noz fully loaded, dismiss scrolling.
        return;
      } else {
        heightOfView = layoutData.layoutPosition!.height - (tableSize.borderWidth * 2);
        if (scrolledIndexTopAligned == null) {
          // Never scrolled = table is at the top
          topViewCutOff = 0;
          bottomViewCutOff = topViewCutOff + heightOfView;
        } else {
          int indexToScrollFrom = lastScrolledToIndex;
          if (headersInTable) {
            indexToScrollFrom++;
          }

          if (scrolledIndexTopAligned!) {
            topViewCutOff = indexToScrollFrom * tableSize.rowHeight;
            bottomViewCutOff = topViewCutOff + heightOfView;
          } else {
            bottomViewCutOff = indexToScrollFrom * tableSize.rowHeight + tableSize.rowHeight;
            topViewCutOff = bottomViewCutOff - heightOfView;
          }
        }
      }

      // Check if the item is visible.
      if (itemTop < topViewCutOff || itemBottom > bottomViewCutOff) {
        // Check if the item is above or below the current view.
        if (itemTop < topViewCutOff) {
          scrolledIndexTopAligned = true;

          // Scroll to the top of the item.
          itemScrollController.scrollTo(index: indexToScrollTo, duration: kThemeAnimationDuration, alignment: 0);
        } else {
          scrolledIndexTopAligned = false;
          // Alignment 1 means the top edge of the item is aligned with the bottom edge of the view
          // Calculates the percentage of the height the top edge of the item is from the top of the view,
          // where the bottom edge of the item touches the bottom edge of the view.
          double alignment = (heightOfView - tableSize.rowHeight) / heightOfView;

          // Scroll to the bottom of the item.
          itemScrollController.scrollTo(
              index: indexToScrollTo, duration: kThemeAnimationDuration, alignment: alignment);
        }

        // Scrolling via the controller does not fire scroll notifications.
        // The last scroll-notification is therefore not updated and would be wrong for
        // the next scroll. Therefore, the last scroll-notification is set to null.
        lastScrollNotification = null;
      }
    }
  }

  /// Selects the record.
  Future<bool> _selectRecord(int pRowIndex, String? pColumnName, {CommandCallback? pAfterSelect}) async {
    if (pRowIndex >= dataChunk.data.length) {
      FlutterUI.logUI.i("Row index out of range: $pRowIndex");
      return false;
    }

    Filter? filter = _createFilter(pRowIndex: pRowIndex);
    if (filter == null) {
      FlutterUI.logUI.w("Filter of table(${model.id}) null");
      return false;
    }

    List<BaseCommand> commands = await IUiService().collectAllEditorSaveCommands(model.id, "Selecting row in table.");

    commands.add(SetFocusCommand(componentId: model.id, focus: true, reason: "Value edit Focus"));

    commands.add(
      SelectRecordCommand(
        dataProvider: model.dataProvider,
        rowNumber: pRowIndex,
        reason: "Tapped",
        filter: filter,
        selectedColumn: pColumnName,
      ),
    );

    if (pAfterSelect != null) {
      commands.add(FunctionCommand(pAfterSelect, reason: "After selected row"));
    }

    return ICommandService().sendCommands(commands, delayUILocking: true);
  }

  /// Sends a [SetValuesCommand] for this row.
  BaseCommand _setValues(int pRowIndex, List<String> pColumnNames, List<dynamic> pValues, String pEditorColumnName) {
    return SetValuesCommand(
      dataProvider: model.dataProvider,
      columnNames: pColumnNames,
      values: pValues,
      filter: _createFilter(pRowIndex: pRowIndex),
      rowNumber: pRowIndex,
      reason: "Values changed in table",
    );
  }

  /// Inserts a new record.
  void _insertRecord() {
    IUiService()
        .saveAllEditors(
      pReason: "Insert row in table",
      pId: model.id,
    )
        .then((success) {
      if (!success) {
        return;
      }

      ICommandService().sendCommands([
        SetFocusCommand(componentId: model.id, focus: true, reason: "Insert on table"),
        _createInsertCommand(),
      ]);
    });
  }

  InsertRecordCommand _createInsertCommand() {
    return InsertRecordCommand(dataProvider: model.dataProvider, reason: "Inserted");
  }

  /// Gets the value of a specified column
  dynamic _getValue({required String pColumnName, int? pRowIndex}) {
    int rowIndex = pRowIndex ?? selectedRow;
    if (rowIndex == -1 || rowIndex >= dataChunk.data.length) {
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

    if (metaData.primaryKeyColumns.isNotEmpty) {
      listColumnNames.addAll(metaData.primaryKeyColumns);
    } else {
      listColumnNames.addAll(metaData.columnDefinitions.map((e) => e.name));
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

  /// Debug feature -> Takes one data provider offline
  void _debugGoOffline() {
    BeamState state = context.currentBeamLocation.state as BeamState;
    String workscreenName = state.pathParameters[MainLocation.screenNameKey]!;
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
      rowNumber: pIndex,
      reason: "Swiped",
      filter: filter,
    );
  }

  BaseCommand? _createSortColumnCommand(String pColumnName, [bool pAdditive = false]) {
    if (!model.sortOnHeaderEnabled) {
      return null;
    }
    ColumnDefinition? coldef = metaData.columnDefinition(pColumnName);

    if (coldef == null || !coldef.sortable) {
      return null;
    }

    SortDefinition? currentSortDefinition = metaData.sortDefinition(pColumnName);
    bool exists = currentSortDefinition != null;

    currentSortDefinition?.mode = currentSortDefinition.nextMode;
    currentSortDefinition ??= SortDefinition(columnName: pColumnName);

    List<SortDefinition> sortDefs;
    if (pAdditive && metaData.sortDefinitions != null) {
      sortDefs = [
        ...metaData.sortDefinitions ?? {},
        if (!exists) currentSortDefinition,
      ];
    } else {
      sortDefs = [currentSortDefinition];
    }

    return SortCommand(
        dataProvider: model.dataProvider, sortDefinitions: sortDefs, reason: "sorted", columnName: pColumnName);
  }

  void _sortColumn(String pColumnName, [bool pAdditive = false]) {
    BaseCommand? sortCommand = _createSortColumnCommand(pColumnName, pAdditive);
    if (sortCommand == null) {
      return;
    }

    IUiService()
        .saveAllEditors(
      pReason: "Select row in table",
      pId: model.id,
    )
        .then((success) {
      if (!success) {
        return;
      }

      ICommandService().sendCommands([
        SetFocusCommand(componentId: model.id, focus: true, reason: "Value edit Focus"),
        sortCommand,
      ]);
    });
  }

  void _editRow(int pRowIndex) {
    _selectRecord(
      pRowIndex,
      null,
      pAfterSelect: () {
        if (IStorageService().isVisibleInUI(model.id) && _isAnyCellInRowEditable(pRowIndex)) {
          List<ColumnDefinition> columnsToShow =
              _getColumnsToShow().where((column) => _isCellEditable(pRowIndex, column.name)).toList();

          Map<String, dynamic> values = {};
          for (ColumnDefinition colDef in columnsToShow) {
            values[colDef.name] = dataChunk.getValue(colDef.name, pRowIndex);
          }

          _showDialog(
            rowIndex: pRowIndex,
            columnDefinitions: columnsToShow,
            values: values,
            onEndEditing: _setValueEnd,
            newValueNotifier: dialogValueNotifier,
          );
        }
        return [];
      },
    );
  }

  List<SlidableAction> createSlideActions(int pRowIndex) {
    List<SlidableAction> slideActions = [];

    if (_isAnyCellInRowEditable(pRowIndex)) {
      slideActions.add(
        SlidableAction(
          onPressed: (context) {
            _editRow(pRowIndex);
          },
          autoClose: true,
          backgroundColor: Colors.green,
          label: FlutterUI.translate("Edit"),
          icon: FontAwesomeIcons.penToSquare,
        ),
      );
    }

    if (_isRowDeletable(pRowIndex)) {
      slideActions.add(
        SlidableAction(
          onPressed: (context) {
            BaseCommand? deleteCommand = _createDeleteCommand(pRowIndex);
            if (deleteCommand != null) {
              ICommandService().sendCommand(deleteCommand);
            }
          },
          autoClose: true,
          backgroundColor: Colors.red,
          label: FlutterUI.translate("Delete"),
          icon: FontAwesomeIcons.trash,
        ),
      );
    }

    return slideActions;
  }

  void _showDialog({
    required int rowIndex,
    required List<ColumnDefinition> columnDefinitions,
    required Map<String, dynamic> values,
    required void Function(dynamic, int, String) onEndEditing,
    required ValueNotifier<Map<String, dynamic>?> newValueNotifier,
    List<dynamic>? dataRow,
  }) {
    if (currentEditDialog == null) {
      if (columnDefinitions.length == 1 &&
          (columnDefinitions.first.cellEditorJson[ApiObjectProperty.className] ==
                  FlCellEditorClassname.LINKED_CELL_EDITOR ||
              columnDefinitions.first.cellEditorJson[ApiObjectProperty.className] ==
                  FlCellEditorClassname.DATE_CELL_EDITOR)) {
        ColumnDefinition colDef = columnDefinitions.first;
        ICellEditor cellEditor = ICellEditor.getCellEditor(
          pName: model.name,
          pCellEditorJson: columnDefinitions.first.cellEditorJson,
          columnDefinition: colDef,
          onChange: (_) {},
          onEndEditing: (value) => onEndEditing(value, rowIndex, colDef.name),
          onFocusChanged: (_) {},
          columnName: colDef.name,
          dataProvider: model.dataProvider,
          isInTable: true,
        );

        if (cellEditor is FlLinkedCellEditor) {
          cellEditor.setValue((values[colDef.name], dataRow));
        } else {
          cellEditor.setValue(values[colDef.name]);
        }

        if (cellEditor is FlDateCellEditor) {
          currentEditDialog = cellEditor.openDatePicker();
        } else if (cellEditor is FlLinkedCellEditor) {
          currentEditDialog = cellEditor.openLinkedCellPicker();
        }
        cellEditor.dispose();
      } else {
        currentEditDialog = IUiService().openDialog(
          pBuilder: (context) => FlTableEditDialog(
            rowIndex: rowIndex,
            model: model,
            columnDefinitions: columnDefinitions,
            values: values,
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

  bool _isDataRow(int pRowIndex) {
    return pRowIndex >= 0 && pRowIndex < dataChunk.data.length;
  }

  bool _isRowDeletable(int pRowIndex) {
    return model.isEnabled &&
        _isDataRow(pRowIndex) &&
        model.deleteEnabled &&
        ((selectedRow == pRowIndex && metaData.deleteEnabled) ||
            (selectedRow != pRowIndex && metaData.modelDeleteEnabled)) &&
        (!metaData.additionalRowVisible || pRowIndex != 0) &&
        !metaData.readOnly;
  }

  bool _isRowEditable(int pRowIndex) {
    if (!_isDataRow(pRowIndex)) {
      return false;
    }

    if (metaData.readOnly) {
      return false;
    }

    if (selectedRow == pRowIndex) {
      if (!metaData.updateEnabled && dataChunk.getRecordStatus(pRowIndex) != RecordStatus.INSERTED) {
        return false;
      }
    } else {
      if (!metaData.modelUpdateEnabled && dataChunk.getRecordStatus(pRowIndex) != RecordStatus.INSERTED) {
        return false;
      }
    }

    return true;
  }

  bool _isCellEditable(int pRowIndex, String pColumn) {
    if (!model.isEnabled) {
      return false;
    }

    ColumnDefinition? colDef = dataChunk.columnDefinition(pColumn);

    if (colDef == null) {
      return false;
    }

    if (!colDef.forcedStateless) {
      if (!_isRowEditable(pRowIndex)) {
        return false;
      }

      if (!model.editable) {
        return false;
      }
    }

    if (colDef.readOnly) {
      return false;
    }

    if (dataChunk.dataReadOnly?[pRowIndex]?[dataChunk.columnDefinitionIndex(pColumn)] ?? false) {
      return false;
    }

    return true;
  }

  bool _isAnyCellInRowEditable(int pRowIndex) {
    return _getColumnsToShow().any((column) => _isCellEditable(pRowIndex, column.name));
  }

  List<ColumnDefinition> _getColumnsToShow() {
    return dataChunk.columnDefinitions.where((element) => tableSize.columnWidths.containsKey(element.name)).toList();
  }
}

enum TableContextMenuItem { INSERT, DELETE, OFFLINE, EDIT, SORT, FETCH }
