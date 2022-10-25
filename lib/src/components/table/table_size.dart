import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

import '../../../util/parse_util.dart';
import '../../model/component/table/fl_table_model.dart';
import '../../model/data/column_definition.dart';
import '../../model/data/subscriptions/data_chunk.dart';
import '../../service/api/shared/fl_component_classname.dart';
import '../editor/cell_editor/i_cell_editor.dart';

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

  /// The table header heigth
  double tableHeaderHeight;

  /// The row height
  double rowHeight;

  /// The cell padding
  EdgeInsets cellPadding;

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
    this.checkCellWidth = 50.0,
    this.imageCellWidth = 50.0,
    this.choiceCellWidth = 50.0,
    this.cellPadding = const EdgeInsets.only(left: 4.0, right: 4.0),
  });

  /// Always calculates the table size.
  TableSize.direct({
    this.borderWidth = 1.0,
    this.columnDividerWidth = 1.0,
    this.minColumnWidth = 50,
    this.maxColumnWidth = 300,
    this.tableHeaderHeight = 50,
    this.rowHeight = 50,
    this.checkCellWidth = 50.0,
    this.imageCellWidth = 50.0,
    this.choiceCellWidth = 50.0,
    this.cellPadding = const EdgeInsets.only(left: 4.0, right: 4.0),
    required FlTableModel tableModel,
    DataChunk? dataChunk,
    double? availableWidth,
  }) {
    calculateTableSize(pTableModel: tableModel, pAvailableWidth: availableWidth, pDataChunk: dataChunk);
  }

  Size get calculatedSize {
    return Size(calculatedColumnWidths.values.sum, tableHeaderHeight + (rowHeight * 10));
  }

  Size get size {
    return Size(columnWidths.values.sum, tableHeaderHeight + (rowHeight * 10));
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  calculateTableSize({
    required FlTableModel pTableModel,
    DataChunk? pDataChunk,
    int pRowsToCalculate = 10,
    double? pAvailableWidth,
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
        "$columnLabel*", // Column headers get a * if they are mandatory
      );
      calculatedColumnWidths[columnName] = _adjustValue(minColumnWidth, calculatedHeaderWidth);

      if (pDataChunk != null) {
        int calculateUntilRowIndex = math.min(
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
            calculatedColumnWidths[columnName] = columnDefinition.width!;
          } else {
            // Get all rows before [calculateUntilRowIndex]
            Iterable<List<dynamic>> dataRows = pDataChunk.data.values.take(calculateUntilRowIndex);

            // Isolate the column from the rows.
            List<dynamic> dataColumn = dataRows.map<dynamic>((e) => e[colIndex!]).toList();

            double calculatedWidth;
            if (columnDefinition.cellEditorClassName == FlCellEditorClassname.CHECK_BOX_CELL_EDITOR) {
              calculatedWidth = checkCellWidth;
            } else if (columnDefinition.cellEditorClassName == FlCellEditorClassname.CHOICE_CELL_EDITOR) {
              calculatedWidth = choiceCellWidth;
            } else if (columnDefinition.cellEditorClassName == FlCellEditorClassname.IMAGE_VIEWER) {
              calculatedWidth = imageCellWidth;
            } else {
              ICellEditor cellEditor = _createCellEditor(columnDefinition.cellEditorJson);

              calculatedWidth = _calculateDataWidth(dataColumn, cellEditor, textStyle);
            }
            calculatedColumnWidths[columnName] = _adjustValue(calculatedColumnWidths[columnName]!, calculatedWidth);
          }
        }
      }
    }

    // Remove any negative widths.
    for (String key in calculatedColumnWidths.keys) {
      calculatedColumnWidths[key] = math.max(0.0, calculatedColumnWidths[key]!);
    }

    columnWidths.clear();
    columnWidths.addAll(calculatedColumnWidths);

    double remainingWidth = pAvailableWidth - size.width;

    // Redistribute the remaining width. AutoSize forces all columns inside the table.
    if (remainingWidth > 0.0) {
      List<String> columnsToRedistribute =
          _getColumnsToRedistribute(pTableModel.columnNames, pDataChunk) ?? pTableModel.columnNames;
      _redistributeRemainingWidth(columnsToRedistribute, remainingWidth);
    } else if (pTableModel.autoResize && remainingWidth < 0.0) {
      int i = 0;
      bool useMinWidth = true;
      while (remainingWidth < 0.0 && i < 30) {
        List<String>? columnsToRedistribute;
        if (useMinWidth) {
          columnsToRedistribute = _getColumnsToRedistribute(pTableModel.columnNames, pDataChunk, minColumnWidth);
          useMinWidth = columnsToRedistribute != null;
        }
        columnsToRedistribute ??= _getColumnsToRedistribute(pTableModel.columnNames, pDataChunk);
        columnsToRedistribute = pTableModel.columnNames;

        _redistributeRemainingWidth(columnsToRedistribute, remainingWidth);

        remainingWidth = pAvailableWidth - size.width;
        i++;
      }
    }
  }

  double _calculateDataWidth(
    List<dynamic> dataColumn,
    ICellEditor pCellEditor,
    TextStyle pTextStyle,
  ) {
    double columnWidth = pCellEditor.getEditorSize(null, true) ?? 0.0;

    Iterable<dynamic> valuesToCheck = dataColumn.whereNotNull();
    for (dynamic value in valuesToCheck) {
      String formattedText = pCellEditor.formatValue(value);

      double rowWidth = _calculateTableTextWidth(pTextStyle, formattedText);

      columnWidth = _adjustValue(columnWidth, rowWidth);
    }

    columnWidth = _adjustValue(columnWidth, columnWidth + pCellEditor.getContentPadding(null, true));

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

    width += cellPadding.horizontal + columnDividerWidth;

    return width;
  }

  void _redistributeRemainingWidth(List<String> pColumnNames, double pRemainingWidth) {
    Map<String, double> currentColumns = Map.from(columnWidths);
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
    // Increases can be given percentually.
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

  ICellEditor _createCellEditor(Map<String, dynamic> pJson) {
    return ICellEditor.getCellEditor(
      pName: "",
      pCellEditorJson: pJson,
      onChange: _doNothing,
      onEndEditing: _doNothing,
    );
  }

  List<String>? _getColumnsToRedistribute(List<String> pColumnNames, DataChunk? pDataChunk,
      [double pMinimumDistributionLimit = 0.0]) {
    if (pDataChunk == null) {
      return pColumnNames;
    }

    List<ColumnDefinition> columnDefinitions =
        pDataChunk.columnDefinitions.where((colDef) => pColumnNames.contains(colDef.name)).toList();

    if (columnDefinitions.isEmpty) {
      return pColumnNames;
    }

    columnDefinitions.removeWhere((element) => (columnWidths[element.name] ?? 0.0) <= pMinimumDistributionLimit);

    if (columnDefinitions.isEmpty) {
      return null;
    }

    Iterable<ColumnDefinition> unconstrainedColDefs = columnDefinitions.where((element) => element.width == null);

    if (unconstrainedColDefs.isNotEmpty) {
      return _getHighestPriorityColumns(unconstrainedColDefs);
    }

    Iterable<ColumnDefinition> constrainedColDefs = columnDefinitions.where((element) => element.width != null);

    return _getHighestPriorityColumns(constrainedColDefs);
  }

  List<String> _getHighestPriorityColumns(Iterable<ColumnDefinition> pColumnDefinitions) {
    Iterable<ColumnDefinition> columnDefinitions;
    if (pColumnDefinitions.any(
      (element) => _fulfillsPriority(_RedistributionPriority.first, element.cellEditorClassName),
    )) {
      columnDefinitions = pColumnDefinitions.where(
        (element) => _fulfillsPriority(_RedistributionPriority.first, element.cellEditorClassName),
      );
    } else if (pColumnDefinitions.any(
      (element) => _fulfillsPriority(_RedistributionPriority.second, element.cellEditorClassName),
    )) {
      columnDefinitions = pColumnDefinitions.where(
        (element) => _fulfillsPriority(_RedistributionPriority.second, element.cellEditorClassName),
      );
    } else if (pColumnDefinitions.any(
      (element) => _fulfillsPriority(_RedistributionPriority.third, element.cellEditorClassName),
    )) {
      columnDefinitions = pColumnDefinitions.where(
        (element) => _fulfillsPriority(_RedistributionPriority.third, element.cellEditorClassName),
      );
    } else {
      columnDefinitions = pColumnDefinitions;
    }

    return columnDefinitions.map((e) => e.name).toList();
  }

  bool _fulfillsPriority(_RedistributionPriority pPriority, String pCellEditorClassName) {
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
