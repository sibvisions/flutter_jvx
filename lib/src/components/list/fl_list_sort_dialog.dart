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

import '../../../flutter_jvx.dart';
import '../../model/command/api/sort_command.dart';
import '../../model/command/ui/set_focus_command.dart';
import '../../model/data/sort_definition.dart';
import '../../util/column_list.dart';
import '../../util/sort_list.dart';

/// A dialog that allows configuration of sort definition.
class FlListSortDialog extends StatefulWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The index of the row to edit.
  final int rowIndex;

  /// The model of the table.
  final FlTableModel model;

  /// The sortable columns
  final ColumnList columnDefinitions;

  /// The sort definitions
  final SortList? sortDefinitions;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlListSortDialog({
    super.key,
    required this.rowIndex,
    required this.model,
    required this.columnDefinitions,
    this.sortDefinitions
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  State<FlListSortDialog> createState() => _FlListSortDialogState();
}

class _FlListSortDialogState extends State<FlListSortDialog> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// If the dialog was dismissed by either button.
  bool dismissedByButton = false;

  /// If cancel button was pressed
  bool cancel = false;

  // If ok button was pressed
  bool ok = false;

  /// The current sort definition
  List<bool?> sortCurrent = [];

  /// The initial sort definition
  List<bool?> sortInitial = [];

  /// The sort order
  List<int?> sortOrder = [];

  /// The initial sort order
  List<String> sortedColumnsInitial = [];

  /// The sorted column names in right order (only sorted columns)
  List<String> sortedColumns = [];

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    super.initState();

    SortDefinition? sort;

    bool? sortMode;

    for (int i = 0; i < widget.columnDefinitions.length; i++) {
      sort = widget.sortDefinitions?.byName(widget.columnDefinitions[i].name);

      sortMode = sort != null ? sort.mode == SortMode.ascending : null;

      sortCurrent.add(sortMode);
      sortInitial.add(sortMode);

      sortOrder.add(widget.sortDefinitions?.indexOf(sort));
    }

    if (widget.sortDefinitions != null) {
      for (int i = 0; i < widget.sortDefinitions!.length; i++) {
        sortedColumns.add(widget.sortDefinitions![i].columnName);
      }
    }

    sortedColumnsInitial.addAll(sortedColumns);
  }

  @override
  void dispose() {
    if (!dismissedByButton) {
      _handleCancel(true);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);

    EdgeInsets paddingInsets;

    paddingInsets = EdgeInsets.fromLTRB(
      screenSize.width / 16,
      screenSize.height / 16,
      screenSize.width / 16,
      screenSize.height / 16,
    );

    ThemeData theme = Theme.of(context);

    return Dialog(
      insetPadding: paddingInsets,
      elevation: 10.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        clipBehavior: Clip.hardEdge,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(4.0))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              FlutterUI.translate("Sort"),
              style: theme.dialogTheme.titleTextStyle ?? (theme.useMaterial3 ? theme.textTheme.titleLarge : theme.textTheme.headlineSmall),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: SingleChildScrollView(
                child: _createSortWidgets(context),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: _handleCancel,
                      child: Text(
                        FlutterUI.translate("Cancel"),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                TextButton(
                  onPressed: _handleOk,
                  child: Text(
                    FlutterUI.translate("OK"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Widget _createSortWidgets(BuildContext context) {

    List<TableRow> rows = [];

    TextStyle style = widget.model.createTextStyle();

    bool? sort;

    for (int i = 0; i < widget.columnDefinitions.length; i++) {
      sort = sortCurrent[i];

      rows.add(TableRow(
        children: [
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child:Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 5, right: 10),
              child: _wrapBadge(Text(widget.columnDefinitions[i].label, style: style), sortOrder[i], widget.columnDefinitions[i].name)
            )
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: ToggleButtons(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                onPressed: (int index) {
                  setState(() {
                    String colName = widget.columnDefinitions[i].name;

                    if (index == 2) {
                      sortCurrent[i] = null;

                      sortedColumns.remove(colName);
                    }
                    else {
                      sortCurrent[i] = index == 1;

                      if (!sortedColumns.contains(colName)) {
                        sortedColumns.add(colName);
                      }
                    }

                    _updateSortOrder();
                  });
                },
                isSelected: [sort == false, sort == true, sort == null],
                children: [const Icon(Icons.sort), Transform.flip(flipY: true, child: const Icon(Icons.sort)), const Icon(Icons.clear)],
              )
            )
          )
        ]
      ));
    }

    Table table = Table(
      /*
      columnWidths: const <int, TableColumnWidth>{
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth()
      },
      */
      children: rows,
    );

    return table;
  }

  Future<void> _handleOk() async {
    ok = true;
    dismissedByButton = true;

    if (!listEquals(sortInitial, sortCurrent) || !listEquals(sortedColumnsInitial, sortedColumns)) {
      SortList sort = SortList();

      for (int i = 0; i < sortedColumns.length; i++) {
        sort.add(SortDefinition(
          columnName: sortedColumns[i],
          mode: sortCurrent[widget.columnDefinitions.indexByName(sortedColumns[i])] == true ? SortMode.ascending : SortMode.descending));
      }

      SortCommand sortCommand = SortCommand(
        dataProvider: widget.model.dataProvider,
        sortDefinition: sort,
        reason: "Sort of ${widget.model.dataProvider}");

      unawaited(ICommandService().sendCommands([
        SetFocusCommand(componentId: widget.model.id, focus: true, reason: "Sort of ${widget.model.dataProvider}"),
        sortCommand,
      ]));
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleCancel([bool fromDispose = false]) async {
    cancel = true;
    dismissedByButton = true;

    if (mounted && !fromDispose) {
      Navigator.of(context).pop();
    }
  }

  Widget _wrapBadge(Widget widget, int? count, String columnName) {
    if (count != null && count >= 0 && sortedColumns.length > 1) {
      return GestureDetector(
        onTap: () {
          int index = sortedColumns.indexOf(columnName);

          if (index < sortedColumns.length - 1) {
            sortedColumns.insert(index + 2, columnName);
            sortedColumns.removeAt(index);
          }
          else {
            sortedColumns.insert(0, columnName);
            sortedColumns.removeAt(index + 1);
          }

          _updateSortOrder();

          setState(() {});
        },
        child: Badge.count(
          backgroundColor: Colors.green,
          alignment: Alignment.topRight,
          count: count + 1,
          offset: const Offset(0, 0),
          child: widget
        )
      );
    }

    return widget;
  }

  void _updateSortOrder() {
    sortOrder.clear();
    for (int i = 0; i < widget.columnDefinitions.length; i++) {
      sortOrder.add(sortedColumns.indexOf(widget.columnDefinitions[i].name));
    }
  }
}
