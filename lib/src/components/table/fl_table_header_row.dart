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

import '../../model/component/fl_component_model.dart';
import '../../model/data/column_definition.dart';
import '../../model/data/sort_definition.dart';
import '../../util/column_list.dart';
import '../../util/sort_list.dart';
import '../base_wrapper/fl_stateless_widget.dart';
import 'fl_table_cell.dart';
import 'fl_table_header_cell.dart';
import 'fl_table_widget.dart';
import 'table_size.dart';

class FlTableHeaderRow extends FlStatelessWidget<FlTableModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Gets called with the name of column when the user taps a cell.
  final TableHeaderTapCallback? onTap;

  /// Gets called with the name of column when the user taps a cell.
  final TableHeaderTapCallback? onDoubleTap;

  /// Gets called with the name of column when the user long presses a cell.
  final TableLongPressCallback? onLongPress;

  /// The colum definitions to build.
  final ColumnList columnDefinitions;

  /// The width of the cell.
  final TableSize tableSize;

  /// The sort definitions
  final SortList? sortDefinitions;

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

    List<Widget> rowWidgets = [];

    int cellIndex = -1;

    //similar code is in fl_table_wrapper.dart -> _getColumnsToShow
    model.columnNames.forEach((colName) {
      ColumnDefinition? cd = columnDefinitions.byName(colName);

      if (cd != null) {
        double colWidth = tableSize.columnWidths[colName] ?? -1;

        if (colWidth > 0) {
          SortDefinition? sortDef = sortDefinitions?.byName(cd.name);

          rowWidgets.add(FlTableHeaderCell(
            model: model,
            onLongPress: onLongPress,
            onTap: onTap,
            onDoubleTap: onDoubleTap,
            columnDefinition: cd,
            width: colWidth,
            paddings: model.autoResize && (colWidth < FlTableCell.clearIconSize + FlTableCell.iconSize +
                                           tableSize.cellPaddings.left + tableSize.cellPaddings.right +
                                           (tableSize.columnFormatWidths[colName] ?? 0)) ? TableSize.paddingsSmall : tableSize.cellPaddings,
            cellDividerWidth: tableSize.columnDividerWidth,
            cellIndex: cellIndex,
            sortMode: sortDef?.mode,
            sortIndex: sortDef != null && sortDefinitions!.length >= 2 ? sortDefinitions!.indexOf(sortDef) + 1 : null,
          ));
        }
      }
    });

    return SizedBox(
      height: tableSize.tableHeaderHeight,
      child: Row(
        children: rowWidgets,
      ),
    );
  }
}
