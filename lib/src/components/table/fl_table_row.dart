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

import '../../../flutter_jvx.dart';
import '../../model/response/record_format.dart';
import '../../util/column_list.dart';
import 'fl_table_cell.dart';

class FlTableRow extends FlStatelessWidget<FlTableModel> {

  /// The width each slide-able action should have
  static const double SLIDEABLE_WIDTH = 125;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The callback if a value has ended being changed in the table.
  final TableValueChangedCallback? onEndEditing;

  /// The callback if a value has been changed in the table.
  final TableValueChangedCallback? onValueChanged;

  /// Gets called with the index of the row and name of column that was touched when the user taps a cell.
  /// Provides the celleditor of this cell, allowing to click the cell editor.
  /// Allows validation of the click before allowing the cell editor to be clicked.
  final TableTapCallback? onTap;

  /// Gets called with the index of the row and name of column when the user long presses a cell.
  final TableLongPressCallback? onLongPress;

  /// The colum definitions to build.
  final ColumnList columnDefinitions;

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

  /// Whether or not specific entries are read only.
  final List<bool>? recordReadOnly;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlTableRow({
    super.key,
    required super.model,
    this.onEndEditing,
    this.onValueChanged,
    this.onTap,
    this.onLongPress,
    this.slideActionFactory,
    required this.columnDefinitions,
    required this.tableSize,
    required this.values,
    required this.index,
    required this.isSelected,
    this.recordFormats,
    this.selectedColumn,
    this.recordReadOnly,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {

    List<Widget> rowWidgets = [];

    int cellIndex = -1;
    double rowWidth = 0;

    //similar code is in fl_table_wrapper.dart -> _getColumnsToShow
    model.columnNames.forEach((colName) {
      ColumnDefinition? cd = columnDefinitions.byName(colName);

      if (cd != null) {
        double colWidth = tableSize.columnWidths[colName] ?? -1;

        if (colWidth > 0) {

          rowWidth += colWidth;

          int cdIndex = columnDefinitions.indexOf(cd);

          rowWidgets.add(FlTableCell(
            model: model,
            onEndEditing: onEndEditing,
            onValueChanged: onValueChanged,
            onLongPress: onLongPress,
            onTap: onTap,
            columnDefinition: cd,
            width: colWidth,
            paddings: model.autoResize && (colWidth < FlTableCell.clearIconSize + FlTableCell.iconSize + tableSize.cellPaddings.left + tableSize.cellPaddings.right) ? TableSize.paddingsSmall : tableSize.cellPaddings,
            cellDividerWidth: tableSize.columnDividerWidth,
            value: values[cdIndex],
            readOnly: recordReadOnly?[cdIndex] ?? false,
            rowIndex: index,
            cellIndex: ++cellIndex,
            cellFormat: recordFormats?.getCellFormat(index, cdIndex),
            isSelected: isSelected && selectedColumn == cd.name,
          ));
        }
      }
    });

    Color? colRow;

    ApplicationSettingsResponse applicationSettings = AppStyle.of(context).applicationSettings;

    double opacity;

    if (model.disabledAlternatingRowColor) {
      opacity = 0;
    } else {

      if (index.isEven) {
        opacity = 0;

        if (JVxColors.isLightTheme(context)) {
          colRow = applicationSettings.colors?.alternateBackground;
        } else {
          colRow = applicationSettings.darkColors?.alternateBackground;
        }
      }
      else {
        opacity = 0.05;

        if (JVxColors.isLightTheme(context)) {
          colRow = applicationSettings.colors?.background;
        } else {
          colRow = applicationSettings.darkColors?.background;
        }
      }
    }

    if (isSelected && model.showSelection) {
      Color? colSelection;

      if (JVxColors.isLightTheme(context)) {
        colSelection = applicationSettings.colors?.activeSelectionBackground;
      } else {
        colSelection = applicationSettings.darkColors?.activeSelectionBackground;
      }

      if (colSelection != null) {
        colRow = colSelection;
      }

      opacity = 0.25;
    }

    colRow ??= Theme.of(context).colorScheme.primary;

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
            color: colRow.withOpacity(opacity),
          ),
          child: Row(
            children: rowWidgets,
          ),
        ),
      ),
    );
  }
}
