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

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

import '../../flutter_ui.dart';
import '../../mask/state/app_style.dart';
import '../../model/command/api/delete_record_command.dart';
import '../../model/command/api/insert_record_command.dart';
import '../../model/command/api/reload_data_command.dart';
import '../../model/command/api/select_record_command.dart';
import '../../model/command/api/set_values_command.dart';
import '../../model/command/base_command.dart';
import '../../model/command/ui/function_command.dart';
import '../../model/command/ui/set_focus_command.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/data/column_definition.dart';
import '../../model/data/data_book.dart';
import '../../model/data/subscriptions/data_chunk.dart';
import '../../model/data/subscriptions/data_record.dart';
import '../../model/request/filter.dart';
import '../../routing/locations/main_location.dart';
import '../../service/command/i_command_service.dart';
import '../../service/data/i_data_service.dart';
import '../../service/ui/i_ui_service.dart';
import '../../util/column_list.dart';
import '../../util/jvx_logger.dart';
import '../../util/offline_util.dart';
import 'table_size.dart';

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

  /// The repaint function
  Function? repaint;

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
  bool isRowDeletable(int rowIndex) {
    return model.isEnabled &&
      isDataRow(rowIndex) &&
      model.deleteEnabled &&
      ((selectedRow == rowIndex && (metaData.deleteEnabled || metaData.modelDeleteEnabled)) ||
       (selectedRow != rowIndex && metaData.modelDeleteEnabled)) &&
      (!metaData.additionalRowVisible || rowIndex != 0) &&
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
      ReloadDataCommand(
        dataProvider: model.dataProvider,
        rowCount: FlutterUI.readAheadLimit,
        reason: "Reload data of ${model.dataProvider}",
      ),
    );
  }

  /// Selects a record by [index].
  Future<CommandResult> selectRecord(int index, {String? columnName, CommandCallback? afterSelectCommand, bool? force}) async {
    if (index >= dataChunk.data.length) {
      FlutterUI.logUI.i("Row index $index out of range (${dataChunk.data.length})");
      return CommandResult(success: false);
    }

    int selectedRowOld = IDataService().getDataBook(model.dataProvider)?.selectedRow ?? -1;

    Filter? filter;

    if (selectedRowOld != index || force == true) {
      filter = createFilter(index);

      if (filter == null) {
        if (FlutterUI.logUI.cl(Lvl.w)) {
          FlutterUI.logUI.w("Filter of (${model.dataProvider}) is null");
        }

        return CommandResult(success: false);
      }
    }

    List<BaseCommand> commands = await IUiService().collectAllEditorSaveCommands(model.id, "Selecting row of ${model.dataProvider}.");

    commands.add(SetFocusCommand(componentId: model.id, focus: true, reason: "Focus because of selecting row of ${model.dataProvider}"));

    if (selectedRowOld != index || force == true) {
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

    return ICommandService().sendCommands(commands, delayUILocking: true).then((result) {
      if (result.success) {
        if (afterSelectCommand != null) {
          afterSelectCommand.call();
        }
      }
      else {
        selectedRowTemporary = null;
        selectedRow = selectedRowOld;

        if (repaint != null) {
          repaint!.call();
        }
      }

      return result;
    });
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
      reason: "Insert record in ${model.dataProvider}",
      id: model.id,
    ).then((result) {
      if (!result.success) {
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
  BaseCommand setValues(int rowIndex, List<String> columnNames, List<dynamic> values, String editorColumnName) {
    return SetValuesCommand(
      dataProvider: model.dataProvider,
      columnNames: columnNames,
      values: values,
      filter: createFilter(rowIndex),
      rowNumber: rowIndex,
      reason: "Values changed in ${model.dataProvider}",
    );
  }

  void setValueOnEndEditing(dynamic value, int row, String columnName) {
    selectRecord(
      row,
      columnName: columnName,
      afterSelectCommand: () {
        int colIndex = metaData.columnDefinitions.indexByName(columnName);

        if (isColumn(row, colIndex)) {
          if (value is Map<String, dynamic>) {
            List<String> columns = [];
            List<dynamic> values = [];

            //only use editable columns
            for (String columnName in value.keys) {
              if (isCellEditable(row, columnName)) {
                columns.add(columnName);
                values.add(value[columnName]);
              }
            }

            //only send if at least one columns is editable
            if (columns.isNotEmpty) {
              return [setValues(row, columns, values, columnName)];
            }
          }
          else {
            if (isCellEditable(row, columnName)) {
              return [setValues(row, [columnName], [value], columnName)];
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
  PopupMenuItem<DataContextMenuItemType> createContextMenuItem(IconData icon, String text, DataContextMenuItemType value, [double ? iconSize]) {
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
              size: iconSize ?? 16,

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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(AppStyle.of(context).direct.popupMenuBorderRadius()),
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