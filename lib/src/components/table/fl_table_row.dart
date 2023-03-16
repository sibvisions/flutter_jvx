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
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../components.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/data/column_definition.dart';
import '../../model/response/dal_fetch_response.dart';
import 'fl_table_cell.dart';

class FlTableRow extends FlStatelessWidget<FlTableModel> {
  /// The width each slideable action should have
  static const double SLIDEABLE_WIDTH = 125;

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

  /// Gets called with the index of the row and name of column that was touched when the user taps a cell.
  /// Provides the celleditor of this cell, allowing to click the cell editor.
  /// Allows validation of the click before allowing the cell editor to be clicked.
  final TableTapCallback? onDoubleTap;

  /// Gets called with the index of the row and name of column when the user long presses a cell.
  final TableLongPressCallback? onLongPress;

  // Fields

  /// The colum definitions to build.
  final List<ColumnDefinition> columnDefinitions;

  /// The width of the cell.
  final TableSize tableSize;

  /// The value of the cell;
  final List<dynamic> values;

  /// The index of the row this column is in.
  final int index;

  /// If this row is selected.
  final bool isSelected;

  /// The selected column;
  final String? selectedColumn;

  /// The record formats
  final RecordFormat? recordFormats;

  /// Which slide actions are to be allowed to the row.
  final TableSlideActionFactory? slideActionFactory;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlTableRow({
    required super.model,
    this.onEndEditing,
    this.onValueChanged,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.slideActionFactory,
    required this.columnDefinitions,
    required this.tableSize,
    required this.values,
    required this.index,
    required this.isSelected,
    this.recordFormats,
    this.selectedColumn,
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

    double rowWidth = 0.0;
    List<Widget> rowWidgets = columnsToShow.map((columnDefinition) {
      cellIndex += 1;
      rowWidth += tableSize.columnWidths[columnDefinition.name]!;

      return FlTableCell(
        model: model,
        onEndEditing: onEndEditing,
        onValueChanged: onValueChanged,
        onLongPress: onLongPress,
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        columnDefinition: columnDefinition,
        width: tableSize.columnWidths[columnDefinition.name]!,
        paddings: tableSize.cellPaddings,
        cellDividerWidth: tableSize.columnDividerWidth,
        value: values[columnDefinitions.indexOf(columnDefinition)],
        rowIndex: index,
        cellIndex: cellIndex,
        cellFormat: recordFormats?.getCellFormat(index, columnDefinitions.indexOf(columnDefinition)),
        isSelected: selectedColumn == columnDefinition.name && isSelected,
      );
    }).toList();

    double opacity = index % 2 == 0 ? 0.00 : 0.05;

    if (isSelected && model.showSelection) {
      opacity = 0.25;
    }

    List<Widget> slideActions = slideActionFactory?.call(index) ?? [];

    double singleActionExtent = SLIDEABLE_WIDTH / rowWidth;
    double slideableExtentRatio = singleActionExtent * slideActions.length;
    slideableExtentRatio = slideableExtentRatio.clamp(0.25, 0.9);
    return Theme(
      data: Theme.of(context).copyWith(
        iconTheme: IconTheme.of(context).copyWith(
          size: 16,
        ),
      ),
      child: Slidable(
        closeOnScroll: true,
        direction: Axis.horizontal,
        enabled: slideActionFactory != null && slideActions.isNotEmpty == true && model.isEnabled,
        groupTag: slideActionFactory,
        endActionPane: ActionPane(
          extentRatio: slideableExtentRatio,
          motion: const ScrollMotion(),
          children: slideActions,
        ),
        child: Container(
          height: tableSize.rowHeight,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(opacity),
          ),
          child: Row(
            children: rowWidgets,
          ),
        ),
      ),
    );
  }
}
