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

import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

import '../../model/component/fl_component_model.dart';
import '../../model/data/column_definition.dart';
import '../../model/data/data_book.dart';
import '../../model/data/subscriptions/data_chunk.dart';
import '../../service/api/shared/fl_component_classname.dart';
import '../../util/parse_util.dart';
import '../editor/cell_editor/fl_check_box_cell_editor.dart';
import '../editor/cell_editor/fl_choice_cell_editor.dart';
import '../editor/cell_editor/fl_image_cell_editor.dart';
import '../editor/cell_editor/i_cell_editor.dart';
import '../editor/cell_editor/linked/fl_linked_cell_editor.dart';
import 'fl_table_cell.dart';

enum _RedistributionPriority { first, second, third }

/// Represents a table size
class TableSize {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The border width outside.
  double borderWidth;

  /// The border width between columns.
  double columnDividerWidth;

  /// The minimum width of a column
  double minColumnWidth;

  /// The maximum width of a column
  double maxColumnWidth;

  /// The table header height
  double tableHeaderHeight;

  /// The row height
  double rowHeight;

  /// The cell padding
  EdgeInsets cellPaddings;

  /// The width of a image cell editor.
  double imageCellWidth;

  /// The width of a checkbox cell editor.
  double checkCellWidth;

  /// The width of a choice cell editor.
  double choiceCellWidth;

  /// The calculated size of the columns
  Map<String, double> calculatedColumnWidths = {};

  /// The size of the columns
  Map<String, double> columnWidths = {};

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  TableSize({
    this.borderWidth = 1.0,
    this.columnDividerWidth = 1.0,
    this.minColumnWidth = 50,
    this.maxColumnWidth = 300,
    this.tableHeaderHeight = 50,
    this.rowHeight = 50,
    this.checkCellWidth = 55.0,
    this.imageCellWidth = 55.0,
    this.choiceCellWidth = 55.0,
    this.cellPaddings = const EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0, bottom: 4.0),
  });

  /// Always calculates the table size.
  TableSize.direct({
    this.borderWidth = 1.0,
    this.columnDividerWidth = 1.0,
    this.minColumnWidth = 50,
    this.maxColumnWidth = 300,
    this.tableHeaderHeight = 50,
    this.rowHeight = 50,
    this.checkCellWidth = 55.0,
    this.imageCellWidth = 55.0,
    this.choiceCellWidth = 55.0,
    this.cellPaddings = const EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0, bottom: 4.0),
    required FlTableModel tableModel,
    required DataChunk dataChunk,
    required DalMetaData metaData,
    double? availableWidth,
  }) {
    calculateTableSize(
        pTableModel: tableModel, pMetaData: metaData, pAvailableWidth: availableWidth, pDataChunk: dataChunk);
  }

  /// The width every column would like to have. Does not include the Border!
  double get calculatedWidth {
    return calculatedColumnWidths.values.sum;
  }

  /// The width every column actually gets allotted. Does not include the Border!
  double get width {
    return columnWidths.values.sum;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  calculateTableSize({
    required FlTableModel pTableModel,
    required DataChunk pDataChunk,
    required DalMetaData pMetaData,
    int pRowsToCalculate = 10,
    double? pAvailableWidth,
    double scaling = 1.0,
  }) {
    calculatedColumnWidths.clear();

    pAvailableWidth = math.max((pAvailableWidth ?? 0.0) - (borderWidth * 2), 0);

    // No data -> No meta data so there cant be fixed sizes.
    TextStyle textStyle = pTableModel.createTextStyle();

    // How far you can calculate with the data we currently have.
    for (int i = 0; i < pTableModel.columnNames.length; i++) {
      String columnName = pTableModel.columnNames[i];
      String columnLabel = pTableModel.columnLabels[i];

      double calculatedHeaderWidth = _calculateTableTextWidth(
        textStyle.copyWith(fontWeight: FontWeight.bold),
        "$columnLabel *", // per default: Column headers get a * if they are mandatory
      );

      if (pMetaData.sortDefinitions?.firstWhereOrNull((element) => element.columnName == columnName)?.mode != null) {
        calculatedHeaderWidth += 21;
      }

      calculatedColumnWidths[columnName] = _adjustValue(minColumnWidth, calculatedHeaderWidth);

      int calculateUntilRow = math.min(
        pDataChunk.data.length,
        pRowsToCalculate,
      );

      int? colIndex;
      ColumnDefinition? columnDefinition = pDataChunk.columnDefinitions.firstWhereIndexedOrNull((index, colDef) {
        if (colDef.name == columnName) {
          colIndex = index;
          return true;
        }
        return false;
      });

      // If there is no column definition found for this column, cant calculate the width.
      if (columnDefinition != null) {
        if (columnDefinition.width != null) {
          if (columnDefinition.cellEditorClassName == FlCellEditorClassname.CHECK_BOX_CELL_EDITOR &&
              columnDefinition.width! <= checkCellWidth) {
            calculatedColumnWidths[columnName] = checkCellWidth;
          } else if (columnDefinition.cellEditorClassName == FlCellEditorClassname.CHOICE_CELL_EDITOR &&
              columnDefinition.width! <= choiceCellWidth) {
            calculatedColumnWidths[columnName] = choiceCellWidth;
          } else if (columnDefinition.cellEditorClassName == FlCellEditorClassname.IMAGE_VIEWER &&
              columnDefinition.width! <= imageCellWidth) {
            calculatedColumnWidths[columnName] = imageCellWidth;
          } else {
            calculatedColumnWidths[columnName] = columnDefinition.width! * scaling;
          }
        } else {
          // Get all rows before [calculateUntilRowIndex]
          List<dynamic> dataRows = [];
          for (int i = 0; i < calculateUntilRow; i++) {
            dataRows.add(pDataChunk.data[i]);
          }

          // Isolate the column from the rows.
          List<dynamic> dataColumn = dataRows.map<dynamic>((e) => e[colIndex!]).toList();

          ICellEditor cellEditor = _createCellEditor(columnDefinition, pMetaData);
          double calculatedWidth;
          if (cellEditor.allowedInTable && cellEditor is FlCheckBoxCellEditor) {
            calculatedWidth = checkCellWidth;
          } else if (cellEditor.allowedInTable && cellEditor is FlChoiceCellEditor) {
            calculatedWidth = choiceCellWidth;
          } else if (cellEditor.allowedInTable && cellEditor is FlImageCellEditor) {
            calculatedWidth = imageCellWidth;
          } else {
            calculatedWidth = _calculateDataWidth(dataRows, dataColumn, cellEditor, textStyle);
          }
          cellEditor.dispose();

          calculatedColumnWidths[columnName] = _adjustValue(calculatedColumnWidths[columnName]!, calculatedWidth);
        }
      }
    }

    // Remove any negative widths.
    for (String key in calculatedColumnWidths.keys) {
      calculatedColumnWidths[key] = math.max(0.0, calculatedColumnWidths[key]!);
    }

    columnWidths.clear();
    columnWidths.addAll(calculatedColumnWidths);

    double remainingWidth = pAvailableWidth - columnWidths.values.sum;

    // Redistribute the remaining width. AutoSize forces all columns inside the table.
    if (remainingWidth > 0.0) {
      _redistributeRemainingWidth(_getColumnsToRedistribute(pDataChunk, false), remainingWidth);
    } else if ((pTableModel.autoResize || remainingWidth >= -10.0) && remainingWidth < 0.0) {
      // '30' is only there to stop if infinite loop happens.
      for (int i = 0; remainingWidth < 0.0 && i < 30; i++) {
        _redistributeRemainingWidth(_getColumnsToRedistribute(pDataChunk), remainingWidth);

        remainingWidth = pAvailableWidth - columnWidths.values.sum;
      }
    }
  }

  double _calculateDataWidth(
    List<dynamic> dataRows,
    List<dynamic> dataColumn,
    ICellEditor cellEditor,
    TextStyle pTextStyle,
  ) {
    double columnWidth = 0.0;

    var valuesToCheck = dataColumn.whereNotNull().toList();
    for (int i = 0; i < valuesToCheck.length; i++) {
      dynamic value = valuesToCheck[i];
      if (cellEditor is FlLinkedCellEditor) {
        cellEditor.setValue((value, dataRows[i]));
      }
      String formattedText = cellEditor.formatValue(value);

      double rowWidth = _calculateTableTextWidth(pTextStyle, formattedText);

      columnWidth = _adjustValue(columnWidth, rowWidth);
    }

    columnWidth = _adjustValue(columnWidth, columnWidth + FlTableCell.getContentPadding(cellEditor));
    return columnWidth;
  }

  double _calculateTableTextWidth(
    TextStyle pTextStyle,
    String pText,
  ) {
    double width = ParseUtil.getTextWidth(
      text: pText,
      style: pTextStyle,
    );

    width += cellPaddings.horizontal + columnDividerWidth;

    return width;
  }

  void _redistributeRemainingWidth(List<String> pColumnNames, double pRemainingWidth) {
    Map<String, double> currentColumns = Map.of(columnWidths);
    currentColumns.removeWhere((key, value) => !pColumnNames.contains(key) || value <= 0.0);
    double currentColumnsWidth = currentColumns.values.sum;

    if (pRemainingWidth > 0.0) {
      _increaseWidths(pColumnNames, pRemainingWidth, currentColumnsWidth);
    } else {
      if (currentColumnsWidth.abs() < pRemainingWidth.abs()) {
        _zeroColumnWidths(pColumnNames);
      } else {
        _decreaseWidths(pColumnNames, pRemainingWidth, currentColumnsWidth);
      }
    }
  }

  void _increaseWidths(List<String> pColumnNames, double pRemainingWidth, double pCurrentColumnsWidth) {
    for (String columnName in pColumnNames) {
      double columnWidth = columnWidths[columnName]!;

      columnWidth += (columnWidths[columnName]! / pCurrentColumnsWidth) * pRemainingWidth;

      columnWidths[columnName] = columnWidth;
    }
  }

  void _zeroColumnWidths(List<String> pColumnNames) {
    for (String columnName in pColumnNames) {
      columnWidths[columnName] = 0.0;
    }
  }

  void _decreaseWidths(List<String> pColumnNames, double pRemainingWidth, double pCurrentColumnsWidth) {
    for (String columnName in pColumnNames) {
      double columnWidth = columnWidths[columnName]!;

      columnWidth += (columnWidths[columnName]! / pCurrentColumnsWidth) * pRemainingWidth;

      columnWidths[columnName] = columnWidth;
    }
  }

  double _adjustValue(double currentWidth, double wantedWith) {
    if (wantedWith > currentWidth) {
      return math.min(math.max(wantedWith, minColumnWidth), maxColumnWidth);
    } else {
      return currentWidth;
    }
  }

  static void _doNothing(dynamic ignore) {}

  ICellEditor _createCellEditor(ColumnDefinition colDef, DalMetaData metaData) {
    return ICellEditor.getCellEditor(
      pName: "",
      pCellEditorJson: colDef.cellEditorJson,
      columnName: colDef.name,
      dataProvider: metaData.dataProvider,
      onChange: _doNothing,
      onEndEditing: _doNothing,
      onFocusChanged: _doNothing,
      isInTable: true,
    );
  }

  List<String> _getColumnsToRedistribute(DataChunk? pDataChunk, [bool pUseMinWidth = true]) {
    List<String> columnNames = columnWidths.keys.toList();

    if (pDataChunk == null) {
      return columnNames;
    }

    List<ColumnDefinition> columnDefinitions =
        pDataChunk.columnDefinitions.where((colDef) => columnNames.contains(colDef.name)).toList();

    if (columnDefinitions.isEmpty) {
      return columnNames;
    }

    if (pUseMinWidth) {
      if (columnDefinitions.none((element) => (columnWidths[element.name] ?? 0.0) > minColumnWidth)) {
        return _getColumnsToRedistribute(pDataChunk, false);
      } else {
        columnDefinitions.removeWhere((element) => (columnWidths[element.name] ?? 0.0) <= minColumnWidth);
      }
    }

    Iterable<ColumnDefinition> unconstrainedColDefs = columnDefinitions.where((element) => element.width == null);

    if (unconstrainedColDefs.isNotEmpty) {
      return _getHighestPriorityColumns(unconstrainedColDefs);
    }

    return _getHighestPriorityColumns(columnDefinitions);
  }

  List<String> _getHighestPriorityColumns(Iterable<ColumnDefinition> pColumnDefinitions) {
    for (_RedistributionPriority rp in _RedistributionPriority.values) {
      if (pColumnDefinitions.any((element) => _fulfillsPriority(rp, element.cellEditorClassName))) {
        return pColumnDefinitions
            .where((element) => _fulfillsPriority(rp, element.cellEditorClassName))
            .map((e) => e.name)
            .toList();
      }
    }

    return pColumnDefinitions.map((e) => e.name).toList();
  }

  bool _fulfillsPriority(_RedistributionPriority pPriority, String? pCellEditorClassName) {
    switch (pPriority) {
      case _RedistributionPriority.first:
        return pCellEditorClassName == FlCellEditorClassname.NUMBER_CELL_EDITOR ||
            pCellEditorClassName == FlCellEditorClassname.TEXT_CELL_EDITOR;
      case _RedistributionPriority.second:
        return pCellEditorClassName == FlCellEditorClassname.LINKED_CELL_EDITOR;
      case _RedistributionPriority.third:
        return pCellEditorClassName == FlCellEditorClassname.DATE_CELL_EDITOR;
    }
  }
}
