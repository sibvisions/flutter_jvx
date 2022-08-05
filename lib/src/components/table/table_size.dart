import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

import '../../../mixin/ui_service_mixin.dart';
import '../../../util/parse_util.dart';
import '../../model/component/table/fl_table_model.dart';
import '../../model/data/column_definition.dart';
import '../../model/data/subscriptions/data_chunk.dart';
import '../editor/cell_editor/i_cell_editor.dart';

/// Represents a table size
class TableSize with UiServiceGetterMixin {
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

  /// The calculated size of the columns
  List<double> calculatedColumnWidths = [];

  /// The size of the columns
  List<double> columnWidths = [];

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
    this.cellPadding = const EdgeInsets.only(left: 4.0, right: 4.0),
    required FlTableModel tableModel,
    DataChunk? dataChunk,
    double? availableWidth,
  }) {
    calculateTableSize(tableModel: tableModel, availableWidth: availableWidth, dataChunk: dataChunk);
  }

  Size get calculatedSize {
    double tableWidth = 0;
    for (int i = 0; i < calculatedColumnWidths.length; i++) {
      tableWidth += calculatedColumnWidths[i];
    }
    return Size(tableWidth, tableHeaderHeight + (rowHeight * 10));
  }

  Size get size {
    double tableWidth = 0;
    for (int i = 0; i < columnWidths.length; i++) {
      tableWidth += columnWidths[i];
    }
    return Size(tableWidth, tableHeaderHeight + (rowHeight * 10));
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  calculateTableSize({
    required FlTableModel tableModel,
    DataChunk? dataChunk,
    double textScaleFactor = 1.0,
    int calculateForRecordCount = 10,
    double? availableWidth,
  }) {
    calculatedColumnWidths.clear();

    availableWidth = (availableWidth ?? 0.0) - (borderWidth * 2);

    List<String> columnHeaders = tableModel.columnLabels ?? tableModel.columnNames;

    for (String columnHeader in columnHeaders) {
      double columnWidth = adjustValue(
        minColumnWidth,
        ParseUtil.getTextWidth(
              text: columnHeader + "*",
              style: tableModel.getTextStyle(pFontWeight: FontWeight.bold),
              textScaleFactor: textScaleFactor,
            ) *
            1.3, // Value is multiplied by 1.3 to make sure that the text is not cut off
        // because the calculated width is too small. Still not sure why, but it works. TODO: investigate
      );

      calculatedColumnWidths.add(columnWidth);
    }

    // get preferred data widths
    if (dataChunk != null) {
      calculateForRecordCount = math.min(
        dataChunk.data.length,
        calculateForRecordCount,
      );

      int colIndex = -1;
      int showIndex = 0;
      for (ColumnDefinition colDef in dataChunk.columnDefinitions) {
        colIndex++;

        if (!tableModel.columnNames.contains(colDef.name)) {
          continue; //Not to be meassured
        } else {
          showIndex = tableModel.columnNames.indexOf(colDef.name);
        }

        double colWidth = minColumnWidth;

        if (colDef.width != null) {
          calculatedColumnWidths[showIndex] = colDef.width!;
        } else {
          ICellEditor cellEditor = ICellEditor.getCellEditor(
            pName: "",
            pCellEditorJson: colDef.cellEditorJson,
            onChange: (_) => null,
            onEndEditing: (_) => null,
            pUiService: getUiService(),
          );

          for (int rowIndex = 0; rowIndex < calculateForRecordCount; rowIndex++) {
            dynamic value = dataChunk.data[rowIndex]![colIndex];

            if (value == null) {
              continue;
            }

            String formattedText = cellEditor.formatValue(value);
            double width = ParseUtil.getTextWidth(
                text: formattedText, style: tableModel.getTextStyle(), textScaleFactor: textScaleFactor);

            width *= 1.3; // Value is multiplied by 1.4 to make sure that the text is not cut off
            // because the calculated width is too small. Still not sure why, but it works.

            width += cellEditor.additionalTablePadding;

            colWidth = adjustValue(colWidth, width);
          }

          // Add padding and add right border
          colWidth = adjustValue(colWidth, colWidth);

          calculatedColumnWidths[showIndex] = adjustValue(calculatedColumnWidths[showIndex], colWidth);
        }
      }
    }

    for (int i = 0; i < calculatedColumnWidths.length; i++) {
      calculatedColumnWidths[i] += (cellPadding.left + cellPadding.right) + columnDividerWidth;
    }

    columnWidths.clear();
    columnWidths.addAll(calculatedColumnWidths);

    if (tableModel.autoResize && calculatedSize.width > availableWidth) {
      redistributeRemainingWidth(availableWidth - calculatedSize.width);
    } else if (calculatedSize.width < availableWidth) {
      redistributeRemainingWidth(availableWidth - calculatedSize.width);
    }
  }

  redistributeRemainingWidth(double pRemainingWidth) {
    double currentWidth = calculatedSize.width;

    for (int i = 0; i < columnWidths.length; i++) {
      double width = columnWidths[i];
      // Every width gets equal share of remaining width
      // Ignores max width, as we have to fill it!
      if (currentWidth > 0.0) {
        width += (width / currentWidth) * pRemainingWidth;
      } else {
        width += pRemainingWidth / columnWidths.length;
      }

      columnWidths[i] = width;
    }
  }

  double adjustValue(double currentWidth, double wantedWith) {
    if (wantedWith > currentWidth) {
      return math.min(math.max(wantedWith, minColumnWidth), maxColumnWidth);
    } else {
      return currentWidth;
    }
  }
}
