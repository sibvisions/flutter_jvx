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

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../components.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/data/column_definition.dart';
import '../../model/data/sort_definition.dart';
import 'fl_table_cell.dart';
import 'fl_table_header_cell.dart';

class FlTableHeaderRow extends FlStatelessWidget<FlTableModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // Callbacks
  /// Gets called with the name of column when the user taps a cell.
  final TableHeaderTapCallback? onTap;

  /// Gets called with the name of column when the user taps a cell.
  final TableHeaderTapCallback? onDoubleTap;

  /// Gets called with the name of column when the user long presses a cell.
  final TableLongPressCallback? onLongPress;

  // Fields
  /// The colum definitions to build.
  final List<ColumnDefinition> columnDefinitions;

  /// The width of the cell.
  final TableSize tableSize;

  /// The sort definitions
  final List<SortDefinition>? sortDefinitions;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlTableHeaderRow({
    required super.model,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    required this.columnDefinitions,
    required this.tableSize,
    this.sortDefinitions,
  }) : super(key: UniqueKey());

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    List<ColumnDefinition> columnsToShow =
        columnDefinitions.where((element) => tableSize.columnWidths.containsKey(element.name)).toList();

    columnsToShow.sort((a, b) => model.columnNames.indexOf(a.name).compareTo(model.columnNames.indexOf(b.name)));

    int cellIndex = -1;
    List<Widget> rowWidgets = columnsToShow.map((columnDefinition) {
      cellIndex += 1;

      SortDefinition? sortDef =
          sortDefinitions?.firstWhereOrNull((element) => element.columnName == columnDefinition.name);

      return FlTableHeaderCell(
        model: model,
        onLongPress: onLongPress,
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        columnDefinition: columnDefinition,
        width: tableSize.columnWidths[columnDefinition.name]!,
        paddings: model.autoResize && (tableSize.columnWidths[columnDefinition.name]! < FlTableCell.clearIconSize + FlTableCell.iconSize + tableSize.cellPaddings.left + tableSize.cellPaddings.right) ? TableSize.paddingsSmall : tableSize.cellPaddings,
        cellDividerWidth: tableSize.columnDividerWidth,
        cellIndex: cellIndex,
        sortMode: sortDef?.mode,
        sortIndex: sortDef != null && sortDefinitions!.length >= 2 ? sortDefinitions!.indexOf(sortDef) + 1 : null,
      );
    }).toList();

    return SizedBox(
      height: tableSize.tableHeaderHeight,
      child: Row(
        children: rowWidgets,
      ),
    );
  }
}
