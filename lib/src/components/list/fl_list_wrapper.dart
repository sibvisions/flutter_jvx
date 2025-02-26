/*
 * Copyright 2025 SIB Visions GmbH
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
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../flutter_jvx.dart';
import '../../model/command/ui/set_focus_command.dart';
import '../../util/column_list.dart';
import '../../util/jvx_logger.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';
import '../editor/cell_editor/i_cell_editor.dart';
import '../table/fl_data_mixin.dart';
import '../table/fl_table_wrapper.dart';

class FlListWrapper extends BaseCompWrapperWidget<FlTableModel> {
  static const int DEFAULT_ITEM_COUNT_PER_PAGE = FlutterUI.readAheadLimit;

  const FlListWrapper({super.key, required super.model});

  @override
  BaseCompWrapperState<FlComponentModel> createState() => _FlListWrapperState();
}

class _FlListWrapperState extends BaseCompWrapperState<FlTableModel> with FlDataMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The bit signaling the meta data has been loaded.
  static const int LOADED_META_DATA = 1;

  /// The bit signaling the selected data has been loaded.
  static const int LOADED_SELECTED_RECORD = 2;

  /// The bit signaling the data has been loaded.
  static const int LOADED_DATA = 4;

  /// The result of all being loaded.
  static const int ALL_COMPLETE = 7;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The current status of the list wrapper.
  int currentState = 0;

  /// How many "pages" of the list data have been loaded multiplied by: [FlTableWrapper.DEFAULT_ITEM_COUNT_PER_PAGE]
  int pageCount = 1;

  /// The cell editors
  Map<String, ICellEditor> cellEditors = {};

  /// The item scroll controller.
  final ItemScrollController itemScrollController = ItemScrollController();

  /// The scroll group to synchronize sticky header scrolling.
  final LinkedScrollControllerGroup linkedScrollGroup = LinkedScrollControllerGroup();

  /// The value notifier for a potential editing dialog.
  ValueNotifier<Map<String, dynamic>?> dialogValueNotifier = ValueNotifier<Map<String, dynamic>?>(null);

  /// The currently opened editing dialog
  Future? currentEditDialog;

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

  /// The last row tapped
  int? lastTappedRow;

  /// The last column tapped
  String? lastTappedColumn;

  /// last loading time in millis
  int _lastLoad = -1;

  /// If the list should show a floating insert button
  bool get showFloatingButton =>
      model.showFloatButton &&
      model.isEnabled &&
      !metaData.readOnly &&
      metaData.insertEnabled &&
      // Only shows the floating button if we are bigger than 100x150
      ((layoutData.layoutPosition?.height ?? 0.0) >= 150) &&
      ((layoutData.layoutPosition?.width ?? 0.0) >= 100);

  /// Whether list is loading data
  bool _loadingData = false;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  _FlListWrapperState() : super();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    super.initState();

    _subscribe();
  }

  @override
  Widget build(BuildContext context) {
    Widget? widget;

    if (currentState != (ALL_COMPLETE)) {
      widget = const Center(child: CircularProgressIndicator());
    }

    widget ??= FlListWidget(
      model: model,
      chunkData: dataChunk,
      metaData: metaData,
      cellEditors: cellEditors,
      slideActionFactory: _createSlideActions,
      selectedRowIndex: selectedRow,
      onRefresh: refresh,
      onEndScroll: _loadMore,
      onScroll: (pScrollNotification) => lastScrollNotification = pScrollNotification,
      onTap: _onListTap,
      onLongPress: _onLongPress,
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

    _disposeCellEditors();

    super.dispose();
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
          to: FlListWrapper.DEFAULT_ITEM_COUNT_PER_PAGE * pageCount,
          onSelectedRecord: _receiveSelectedRecord,
          onDataChunk: _receiveListData,
          onMetaData: _receiveMetaData,
          onReload: _onDataProviderReload,
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
      pageCount = ((selectedRow + 1) / FlListWrapper.DEFAULT_ITEM_COUNT_PER_PAGE).ceil();
    } else {
      pageCount = 1;
    }

    return FlListWrapper.DEFAULT_ITEM_COUNT_PER_PAGE * pageCount;
  }

  /// Loads data from the server.
  void _receiveListData(DataChunk pDataChunk) {
    currentState |= LOADED_DATA;

    dataChunk = pDataChunk;

    if (isDataRow(selectedRow)) {
      Map<String, dynamic> selectionValues = {};

      for (ColumnDefinition colDef in dataChunk.columnDefinitions) {
        selectionValues[colDef.name] = dataChunk.data[selectedRow]![dataChunk.columnDefinitions.indexByName(colDef.name)];
      }

      dialogValueNotifier.value = selectionValues;
    }

    _loadingData = false;

    setState(() {});
  }

  /// Receives which row is selected.
  void _receiveSelectedRecord(DataRecord? pRecord) {
    currentState |= LOADED_SELECTED_RECORD;

    var currentSelectedRow = selectedRow;

    if (pRecord != null) {
      selectedRow = pRecord.index;
    } else {
      DataBook? dataBook = IDataService().getDataBook(model.dataProvider);
      if (dataBook != null) {
        selectedRow = dataBook.selectedRow;
      } else {
        selectedRow = -1;
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
    if (selectedRow >= (pageCount * FlListWrapper.DEFAULT_ITEM_COUNT_PER_PAGE)) {
      pageCount = ((selectedRow + 1) / FlListWrapper.DEFAULT_ITEM_COUNT_PER_PAGE).ceil();
      _subscribe();
    }

    setState(() {});
  }

  /// Receives the meta data of the table.
  void _receiveMetaData(DalMetaData pMetaData) {
    currentState |= LOADED_META_DATA;

    metaData = pMetaData;

    _rebuildCellEditors();

    setState(() {});
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Disposes all created cell editors
  void _disposeCellEditors() {
    for (ICellEditor ced in cellEditors.values) {
      ced.dispose();
    }

    cellEditors.clear();
  }

  /// Rebuilds cell editors for all columns
  void _rebuildCellEditors() {
    _disposeCellEditors();

    ColumnList colDef = metaData.columnDefinitions;

    for (int i = 0; i < colDef.length; i++) {
      ICellEditor ced = ICellEditor.getCellEditor(
        pName: widget.model.name,
        columnDefinition: colDef[i],
        columnName: colDef[i].name,
        dataProvider: widget.model.dataProvider,
        pCellEditorJson: colDef[i].cellEditorJson,
        isInTable: true,
      );

      cellEditors[colDef[i].name] = ced;
    }
  }

  /// Increments the page count and loads more data.
  bool _loadMore() {
    int now = DateTime.now().millisecondsSinceEpoch;
    if (!dataChunk.isAllFetched && !_loadingData && _lastLoad + 200 < now) {

      _loadingData = true;
      _lastLoad = now;

      pageCount++;
      _subscribe();

      return true;
    }

    return false;
  }

  /// Scrolls the list to the selected row if it is not visible.
  /// Can only be called in the post frame callback as the scroll controller
  /// otherwise has not yet been updated with the most recent items.
  void _scrollToSelected() {
    if (lastScrolledToIndex == selectedRow) {
      return;
    }

    lastScrolledToIndex = selectedRow;
  }

  /// Creates actions for row slidable
  List<SlidableAction> _createSlideActions(BuildContext context, int index) {
    List<SlidableAction> slideActions = [];

    bool isLight = JVxColors.isLightTheme(context);

    if (isAnyCellInRowEditable(index)) {
      slideActions.add(
        SlidableAction(
          onPressed: (context) {
            _editRow(index);
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

    if (isRowDeletable(index)) {
      slideActions.add(
        SlidableAction(
          onPressed: (context) {
            String? status = dataChunk.getRecordStatusRaw(index);

            //sometimes this event is triggered more than once, so don't delete again
            if (status != null && !status.contains("SLIDE_DELETE")) {
              if (status.isNotEmpty) {
                dataChunk.setStatusRaw(index, "$status,SLIDE_DELETE");
              }
              else {
                dataChunk.setStatusRaw(index, "SLIDE_DELETE");
              }

              BaseCommand? deleteCommand = createDeleteCommand(index);

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

  void _onListTap(int index) {
      if (FlutterUI.logUI.cl(Lvl.d)) {
        FlutterUI.logUI.d("List cell tapped: $index");
//        FlutterUI.logUI.d("Active last single tap timer: ${lastSingleTapTimer?.isActive}");
      }

      selectRecord(index);
/*
      if (lastTappedColumn == pColumnName && lastTappedRow == pRowIndex && lastSingleTapTimer?.isActive == true) {
        if (FlutterUI.logUI.cl(Lvl.d)) {
          FlutterUI.logUI.d("Tap type: double");
        }
        lastTappedColumn = null;
        lastTappedRow = null;
        lastSingleTapTimer?.cancel();
        lastSelectionTapFuture?.then((value) {
          if (FlutterUI.logUI.cl(Lvl.d)) {
            FlutterUI.logUI.d("Selecting was: $value");
          }

          if (value) {
            if (FlutterUI.logUI.cl(Lvl.d)) {
              FlutterUI.logUI.d("Double tap action");
            }

            _onDoubleTap(pRowIndex, pColumnName, pCellEditor);
          }
        });
      } else {
        if (FlutterUI.logUI.cl(Lvl.d)) {
          FlutterUI.logUI.d("Tap type: single");
        }
        lastTappedColumn = pColumnName;
        lastTappedRow = pRowIndex;
        lastSingleTapTimer?.cancel();
        lastSelectionTapFuture = _selectRecord(pRowIndex, pColumnName);
        lastSingleTapTimer = Timer(const Duration(milliseconds: 300), () {
          lastSelectionTapFuture?.then((value) {
            if (FlutterUI.logUI.cl(Lvl.d)) {
              FlutterUI.logUI.d("Selecting was: $value");
            }

            if (value) {
              FlutterUI.logUI.d("Single tap action");

              _onSingleTap(pRowIndex, pColumnName, pCellEditor);
            }
          });
        });
      }
 */
  }

  _onLongPress(int index, Offset pGlobalPosition) {
    List<PopupMenuEntry<DataContextMenuItemType>> popupMenuEntries = <PopupMenuEntry<DataContextMenuItemType>>[];

    int separator = 0;

    if (kDebugMode) {
      popupMenuEntries.add(createContextMenuItem(Icons.cloud_off, "Offline", DataContextMenuItemType.OFFLINE));
      separator++;
    }

    if (model.sortOnHeaderEnabled) {
      popupMenuEntries.add(createContextMenuItem(FontAwesomeIcons.sort, "Sort", DataContextMenuItemType.SORT));
      separator++;
    }

    if (metaData.insertEnabled && !metaData.readOnly) {
      popupMenuEntries.add(createContextMenuItem(FontAwesomeIcons.squarePlus, "New", DataContextMenuItemType.INSERT));
    }

    if (isRowDeletable(index)) {
      popupMenuEntries.add(createContextMenuItem(FontAwesomeIcons.squareMinus, "Delete", DataContextMenuItemType.DELETE));
    }

    if (isAnyCellInRowEditable(index)) {
      popupMenuEntries.add(createContextMenuItem(FontAwesomeIcons.penToSquare, "Edit", DataContextMenuItemType.EDIT));
    }

    if (separator > 0 && popupMenuEntries.length > separator) {
      popupMenuEntries.insert(separator, const PopupMenuDivider(height: 3));
    }

    if (popupMenuEntries.isNotEmpty) {
      showPopupMenu(context, pGlobalPosition, popupMenuEntries).then((type) {
        if (type != null) {
          _menuItemPressed(type, index);
        }
      });
    }
  }

  void _menuItemPressed(DataContextMenuItemType type, int index) {
    IUiService().saveAllEditors(
      pId: model.id,
      pReason: "List menu item pressed",
    ).then((success) {
      if (!success) {
        return;
      }

      List<BaseCommand> commands = [];

      if (type == DataContextMenuItemType.OFFLINE) {
        if (mounted) {
          debugGoOffline(context);
        }
      }
      else if (type == DataContextMenuItemType.SORT) {

      }
      else if (type == DataContextMenuItemType.INSERT) {
        commands.add(createInsertCommand());
      } else if (type == DataContextMenuItemType.DELETE) {
        BaseCommand? command = createDeleteCommand(index);

        if (command != null) {
          commands.add(command);
        }
      }
      else if (type == DataContextMenuItemType.EDIT) {
        _editRow(index);
      }
      else if (type == DataContextMenuItemType.RELOAD) {
        unawaited(refresh());
      }

      if (commands.isNotEmpty) {
        commands.insert(0, SetFocusCommand(componentId: model.id, focus: true, reason: "Popup command Focus"));

        ICommandService().sendCommands(commands);
      }
    });
  }

  /// Edits row at [index]
  void _editRow(int index) {
    selectRecord(
      index,
      afterSelectCommand: () {
        if (IStorageService().isVisibleInUI(model.id) && isAnyCellInRowEditable(index)) {
          var editColumns = getEditableColumns(index);

          _showDialog(
            rowIndex: index,
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

  void _showDialog({
    required int rowIndex,
    required ColumnList columnDefinitions,
    required Map<String, dynamic> values,
    required void Function(dynamic, int, String) onEndEditing,
    required ValueNotifier<Map<String, dynamic>?> newValueNotifier
  }) {
    if (columnDefinitions.isEmpty) {
      _closeDialog();
    }
    else if (currentEditDialog == null) {
      currentEditDialog = IUiService().openDialog(
        pBuilder: (context) => FlTableEditDialog(
          rowIndex: rowIndex,
          model: model,
          columnDefinitions: columnDefinitions,
          values: values,
          onEndEditing: onEndEditing,
          newValueNotifier: newValueNotifier,
        )
      );

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
