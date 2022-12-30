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

class FlTableRow extends FlStatefulWidget<FlTableModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // Callbacks

  /// The callback if a value has ended beeing changed in the table.
  final TableValueChangedCallback? onEndEditing;

  /// The callback if a value has been changed in the table.
  final TableValueChangedCallback? onValueChanged;

  /// Gets called with the index of the row and name of column that was touched when the user taps a cell.
  /// Provides the celleditor of this cell, allowing to click the cell editor.
  /// Allows validation of the click before allowing the cell editor to be clicked.
  final TableTapCallback? onTap;

  /// Gets called with the index of the row and name of column when the user long presses a cell.
  final TableLongPressCallback? onLongPress;

  /// Gets called when an action cell editor makes an action.
  final CellEditorActionCallback? onAction;

  // Fields

  /// The colum definitions to build.
  final List<ColumnDefinition> columnDefinitions;

  /// The width of the cell.
  final TableSize tableSize;

  /// The value of the cell;
  final List<dynamic> values;

  /// The index of the row this column is in.
  final int index;

  /// If the cells are forced to only display text widgets
  final bool disableEditors;

  /// If this row is selected.
  final bool isSelected;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlTableRow({
    required super.model,
    this.onEndEditing,
    this.onValueChanged,
    this.onTap,
    this.onLongPress,
    this.onAction,
    required this.columnDefinitions,
    required this.tableSize,
    required this.values,
    required this.index,
    required this.isSelected,
    this.disableEditors = false,
  }) : super(key: UniqueKey());

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  State<FlTableRow> createState() => _FlTableRowState();
}

class _FlTableRowState extends State<FlTableRow> {
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
        onEndEditing: widget.onEndEditing,
        onValueChanged: widget.onValueChanged,
        onLongPress: widget.onLongPress,
        onTap: widget.onTap,
        onAction: widget.onAction,
        columnDefinition: columnDefinition,
        width: widget.tableSize.columnWidths[columnDefinition.name]!,
        paddings: widget.tableSize.cellPaddings,
        cellDividerWidth: widget.tableSize.columnDividerWidth,
        value: widget.values[widget.columnDefinitions.indexOf(columnDefinition)],
        rowIndex: widget.index,
        disableEditor: widget.disableEditors,
        cellIndex: cellIndex,
      );
    }).toList();

    double opacity = widget.index % 2 == 0 ? 0.00 : 0.05;

    if (widget.isSelected) {
      opacity = 0.25;
    }

    return Container(
      height: widget.tableSize.rowHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(opacity),
      ),
      child: Row(
        children: rowWidgets,
      ),
    );
  }
}
