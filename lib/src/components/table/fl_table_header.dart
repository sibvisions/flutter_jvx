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

import 'package:flutter/material.dart';

import '../../../flutter_jvx.dart';
import '../base_wrapper/fl_stateful_widget.dart';
import 'fl_table_cell.dart';

class FlTableHeader extends FlStatefulWidget<FlTableModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // Callbacks

  /// Gets called with the index of the row and name of column that was touched when the user taps a cell.
  /// Provides the celleditor of this cell, allowing to click the cell editor.
  /// Allows validation of the click before allowing the cell editor to be clicked.
  final Function(String column)? onTap;

  /// Gets called with the index of the row and name of column when the user long presses a cell.
  final Function(int rowIndex, String column, LongPressStartDetails details)? onLongPress;

  // Fields
  /// The colum definitions to build.
  final List<ColumnDefinition> columnDefinitions;

  /// The width of the cell.
  final TableSize tableSize;
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlTableHeader({
    required super.model,
    required this.onTap,
    required this.onLongPress,
    required this.columnDefinitions,
    required this.tableSize,
  }) : super(key: UniqueKey());

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  State<FlTableHeader> createState() => _FlTableHeaderState();
}

class _FlTableHeaderState extends State<FlTableHeader> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    List<ColumnDefinition> columnsToShow = widget.tableSize.columnWidths.keys
        .map((e) => widget.columnDefinitions.firstWhere((element) => element.name == e))
        .toList();

    int cellIndex = -1;
    List<Widget> rowWidgets = columnsToShow.map((columnDefinition) {
      cellIndex += 1;
      return FlTableCell(
        model: widget.model,
        onLongPress: widget.onLongPress,
        onTap: widget.onTap != null ? ((rowIndex, column, cellEditor) => widget.onTap!(column)) : null,
        columnDefinition: columnDefinition,
        width: widget.tableSize.columnWidths[columnDefinition.name]!,
        paddings: widget.tableSize.cellPaddings,
        cellDividerWidth: widget.tableSize.columnDividerWidth,
        cellIndex: cellIndex,
        isHeader: true,
      );
    }).toList();

    return SizedBox(
      height: widget.tableSize.tableHeaderHeight,
      child: Row(
        children: rowWidgets,
      ),
    );
  }
}
