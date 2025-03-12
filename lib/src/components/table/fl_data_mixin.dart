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

import 'package:flutter/material.dart';

import '../../../flutter_jvx.dart';
import '../../model/command/ui/set_focus_command.dart';
import '../../util/column_list.dart';
import '../../util/jvx_logger.dart';
import '../../util/offline_util.dart';

enum DataContextMenuItemType { OFFLINE, SORT, INSERT, DELETE, EDIT, RELOAD }

mixin FlDataMixin {

  /// The table model
  FlTableModel get model;

  /// The data of the.
  DataChunk dataChunk = DataChunk.empty();

  /// The meta data of the.
  DalMetaData metaData = DalMetaData();

  /// The columns to show (based on [model.columnNames])
  ColumnList? columnsToShow;

  /// The sizes of the table.
  TableSize? tableSize;

  /// The currently selected row. -1 is none selected.
  int selectedRow = -1;

  /// The selected row, only temporary
  int? selectedRowTemporary;

  /// The last selected row of build run
  int lastSelectedRow = -2;

  /// Gets whether the row [index] is a available in data chunk.
  bool isDataRow(int index) {
    return index >= 0 && index < dataChunk.data.length;
  }

  bool isColumn(int rowIndex, int columnIndex) {
    return isDataRow(rowIndex) && columnIndex >= 0 && columnIndex < dataChunk.data[rowIndex]!.length;
  }

  /// Gets whether the row at [index] can be deleted.
  bool isRowDeletable(int pRowIndex) {
    return model.isEnabled &&
      isDataRow(pRowIndex) &&
      model.deleteEnabled &&
      ((selectedRow == pRowIndex && (metaData.deleteEnabled || metaData.modelDeleteEnabled)) ||
       (selectedRow != pRowIndex && metaData.modelDeleteEnabled)) &&
      (!metaData.additionalRowVisible || pRowIndex != 0) &&
      !metaData.readOnly;
  }

  /// Gets whether the row at [index] can be edited.
  bool isRowEditable(int index) {
    if (!isDataRow(index)) {
      return false;
    }

    if (metaData.readOnly) {
      return false;
    }

    if (selectedRow == index) {
      if (!metaData.updateEnabled && !metaData.modelUpdateEnabled && dataChunk.getRecordStatus(index) != RecordStatus.INSERTED) {
        return false;
      }
    } else {
      if (!metaData.modelUpdateEnabled && dataChunk.getRecordStatus(index) != RecordStatus.INSERTED) {
        return false;
      }
    }

    return true;
  }

  /// Gets whether the [columnName] at row [index] is editable.
  bool isCellEditable(int index, String columnName) {
    if (!model.isEnabled) {
      return false;
    }

    ColumnDefinition? colDef = dataChunk.columnDefinitions.byName(columnName);

    if (colDef == null) {
      return false;
    }

    if (!colDef.forcedStateless) {
      if (!isRowEditable(index)) {
        return false;
      }

      if (!model.editable) {
        return false;
      }
    }

    if (colDef.readOnly) {
      return false;
    }

    if (dataChunk.dataReadOnly?[index]?[dataChunk.columnDefinitions.indexByName(columnName)] ?? false) {
      return false;
    }

    return true;
  }

  /// Gets whether the [columnName] at row [index] is sortable.
  bool isSortable(String columnName) {
    if (!model.isEnabled) {
      return false;
    }

    ColumnDefinition? colDef = dataChunk.columnDefinitions.byName(columnName);

    if (colDef == null) {
      return false;
    }

    return colDef.sortable;
  }

  /// Creates an identifying filter for the given row [index].
  Filter? createFilter(int index) {
    List<String> listColumnNames = [];
    List<dynamic> listValues = [];

    if (metaData.primaryKeyColumns.isNotEmpty) {
      listColumnNames.addAll(metaData.primaryKeyColumns);
    } else {
      listColumnNames.addAll(metaData.columnDefinitions.map((e) => e.name));
    }

    for (String column in listColumnNames) {
      listValues.add(_getValue(column, index));
    }

    return Filter(values: listValues, columnNames: listColumnNames);
  }

  /// Refreshes data current provider
  Future<void> refresh() {
    IUiService().notifySubscriptionsOfReload(model.dataProvider);

    return ICommandService().sendCommand(
      FetchCommand(
        fromRow: 0,
        reload: true,
        rowCount: IUiService().getSubscriptionRowCount(model.dataProvider),
        dataProvider: model.dataProvider,
        reason: "Refresh data of ${model.dataProvider}",
      ),
    );
  }

  /// Selects a record by [index].
  Future<bool> selectRecord(int index, {String? columnName, CommandCallback? afterSelectCommand, bool? force}) async {
    if (index >= dataChunk.data.length) {
      FlutterUI.logUI.i("Row index $index out of range (${dataChunk.data.length})");
      return false;
    }

    int selectedRow = IDataService().getDataBook(model.dataProvider)?.selectedRow ?? -1;

    Filter? filter;

    if (selectedRow != index || force == true) {
      filter = createFilter(index);

      if (filter == null) {
        if (FlutterUI.logUI.cl(Lvl.w)) {
          FlutterUI.logUI.w("Filter of (${model.dataProvider}) is null");
        }

        return false;
      }
    }

    List<BaseCommand> commands = await IUiService().collectAllEditorSaveCommands(model.id, "Selecting row of ${model.dataProvider}.");

    commands.add(SetFocusCommand(componentId: model.id, focus: true, reason: "Focus because of selecting row of ${model.dataProvider}"));

    if (selectedRow != index || force == true) {
      commands.add(
        SelectRecordCommand(
          dataProvider: model.dataProvider,
          rowNumber: index,
          reason: "Select record",
          filter: filter!,
          selectedColumn: columnName?.isNotEmpty == true ? columnName : null,
        ),
      );
    }

    if (afterSelectCommand != null) {
      commands.add(FunctionCommand(afterSelectCommand, reason: "After selected row of ${model.dataProvider}"));
    }

    return ICommandService().sendCommands(commands, delayUILocking: true);
  }

  /// Creates an [InsertRecordCommand].
  InsertRecordCommand createInsertCommand({int? rowNumber, bool? before}) {
    return InsertRecordCommand(
      dataProvider: model.dataProvider,
      rowNumber: rowNumber,
      before: before,
      reason: "Insert record in ${model.dataProvider}"
    );
  }

  /// Inserts a new record.
  void insertRecord() {
    IUiService().saveAllEditors(
      pReason: "Insert record in ${model.dataProvider}",
      pId: model.id,
    ).then((success) {
      if (!success) {
        return;
      }

      ICommandService().sendCommands([
        SetFocusCommand(componentId: model.id, focus: true, reason: "Insert record in ${model.dataProvider}"),
        createInsertCommand(),
      ]);
    });
  }

  /// Creates a delete command for the given row [index].
  DeleteRecordCommand? createDeleteCommand(int index) {
    Filter? filter = createFilter(index);

    if (filter == null) {
      if (FlutterUI.logUI.cl(Lvl.w)) {
        FlutterUI.logUI.w("Filter of (${model.id}) is null");
      }

      return null;
    }

    return DeleteRecordCommand(
      dataProvider: model.dataProvider,
      rowNumber: index,
      reason: "Delete record $index of ${model.dataProvider}",
      filter: filter,
    );
  }

  /// Debug feature -> Takes data provider offline
  void debugGoOffline(BuildContext context) {
    BeamState state = context.currentBeamLocation.state as BeamState;
    OfflineUtil.initOffline(state.pathParameters[MainLocation.screenNameKey]!);
  }

  /// Sends a [SetValuesCommand] for this row.
  BaseCommand setValues(int pRowIndex, List<String> pColumnNames, List<dynamic> pValues, String pEditorColumnName) {
    return SetValuesCommand(
      dataProvider: model.dataProvider,
      columnNames: pColumnNames,
      values: pValues,
      filter: createFilter(pRowIndex),
      rowNumber: pRowIndex,
      reason: "Values changed in ${model.dataProvider}",
    );
  }

  void setValueOnEndEditing(dynamic pValue, int pRow, String pColumnName) {
    selectRecord(
      pRow,
      columnName: pColumnName,
      afterSelectCommand: () {
        int colIndex = metaData.columnDefinitions.indexByName(pColumnName);

        if (isColumn(pRow, colIndex)) {
          if (pValue is Map<String, dynamic>) {
            List<String> columns = [];
            List<dynamic> values = [];

            //only use editable columns
            for (String columnName in pValue.keys) {
              if (isCellEditable(pRow, columnName)) {
                columns.add(columnName);
                values.add(pValue[columnName]);
              }
            }

            //only send if at least one columns is editable
            if (columns.isNotEmpty) {
              return [setValues(pRow, columns, values, pColumnName)];
            }
          }
          else {
            if (isCellEditable(pRow, pColumnName)) {
              return [setValues(pRow, [pColumnName], [pValue], pColumnName)];
            }
          }
        }

        return [];
      },
    );
  }

  /// Gets the value of a specified column for a specific row [index] or the selected row
  dynamic _getValue(String columnName, [int? index]) {
    int rowIndex = index ?? selectedRow;

    if (rowIndex == -1 || rowIndex >= dataChunk.data.length) {
      return;
    }

    int colIndex = dataChunk.columnDefinitions.indexByName(columnName);

    if (colIndex == -1) {
      return;
    }

    return dataChunk.data[rowIndex]![colIndex];
  }

  /// Creates a single item for a popup menu.
  PopupMenuItem<DataContextMenuItemType> createContextMenuItem(IconData icon, String text, DataContextMenuItemType value) {
    return PopupMenuItem<DataContextMenuItemType>(
      enabled: true,
      value: value,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 28,
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 16,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 10),
            child: Text(
              FlutterUI.translate(text),
              style: model.createTextStyle(),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows a popup menu with [items]
  Future<T?> showPopupMenu<T>(BuildContext context, Offset position, List<PopupMenuEntry<T>> items) async {
    Size size = MediaQuery.sizeOf(context);

    return showMenu(
      constraints: const BoxConstraints(
        minWidth: 50,
        maxWidth: 150
      ),
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        size.width,
        size.height
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(JVxColors.BORDER_RADIUS),
        ),
      ),
      context: context,
      items: items
    );
  }

  /// Gets whether at least one column in the given row by [index] is editable
  bool isAnyCellInRowEditable(int index) {
    List<ColumnDefinition> colDefs = getColumnsToShow();

    for (int i = 0; i < colDefs.length; i++) {
      if (isCellEditable(index, colDefs[i].name)) {
        return true;
      }
    }

    return false;
  }

  /// Gets all columns which can be shown
  List<ColumnDefinition> getColumnsToShow() {
    if (columnsToShow == null || columnsToShow!.isEmpty) {
      columnsToShow = ColumnList.empty();

      String colName;

      for (int i = 0; i < model.columnNames.length; i++) {
        colName = model.columnNames[i];

        ColumnDefinition? cd = dataChunk.columnDefinitions.byName(colName);

        if (cd != null) {
          if (tableSize != null) {
            double colWidth = tableSize!.columnWidths[colName] ?? -1;

            if (colWidth > 0) {
              columnsToShow!.add(cd);
            }
          }
          else {
            columnsToShow!.add(cd);
          }
        }
      }
    }

    return columnsToShow!;
  }

  ({ColumnList columns, Map<String, dynamic> values}) getEditableColumns(int index) {
      List<ColumnDefinition> colDefs = getColumnsToShow();

      String colName;

      ColumnList editableColumns = ColumnList();
      Map<String, dynamic> values = {};

      //We need all editable columns and the values
      for (int i = 0; i < colDefs.length; i++) {
          colName = colDefs[i].name;

          if (isCellEditable(index, colName)) {
              editableColumns.add(colDefs[i]);
              values[colName] = dataChunk.getValue(colName, index);
          }
      }

      return (columns: editableColumns, values: values);
  }

  /// Gets all sortable columns
  ColumnList getSortableColumns() {
    List<ColumnDefinition> colDefs = getColumnsToShow();

    String colName;

    ColumnList sortableColumns = ColumnList();

    //We need all editable columns and the values
    for (int i = 0; i < colDefs.length; i++) {
      colName = colDefs[i].name;

      if (isSortable(colName)) {
        sortableColumns.add(colDefs[i]);
      }
    }

    return sortableColumns;
  }

}