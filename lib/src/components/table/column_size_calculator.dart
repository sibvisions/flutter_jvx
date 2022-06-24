import 'dart:developer' as dev;
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

import '../../../util/parse_util.dart';
import '../../model/component/table/fl_table_model.dart';
import '../../model/data/column_definition.dart';
import '../../model/data/subscriptions/data_chunk.dart';

class ColumnSizeCalculator {
  static TableSize calculateTableSize({
    required FlTableModel tableModel,
    DataChunk? dataChunk,
    double textScaleFactor = 1.0,
    int calculateForRecordCount = 10,
    double? availableWidth,
  }) {
    TableSize tableSize = TableSize();

    availableWidth = (availableWidth ?? 0.0) - (TableSize.borderWidth * 2);

    List<String> columnHeaders = tableModel.columnLabels ?? tableModel.columnNames;

    for (String columnHeader in columnHeaders) {
      double columnWidth = adjustValue(
        TableSize.defaultMinWidth,
        ParseUtil.getTextWidth(
              text: columnHeader,
              style: tableModel.getTextStyle(pFontWeight: FontWeight.bold),
              textScaleFactor: textScaleFactor,
            ) *
            1.3, // Value is multiplied by 1.3 to make sure that the text is not cut off
        // because the calculated width is too small. Still not sure why, but it works. TODO: investigate
      );

      tableSize.columnWidths.add(columnWidth);
      tableSize.calculatedColumnWidths.add(columnWidth);
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

        double colWidth = TableSize.defaultMinWidth;

        if (colDef.width != null) {
          colWidth = adjustValue(colWidth, colDef.width!);
        }

        // if (colDef.cellEditor.model.directCellEditor) {
        //   // Calculate width of this column with formattings of this cell editor
        //   double? width = colDef.cellEditor.createWidgetModel().preferredSize?.width;
        //   if (width != null) {
        //     colWidth = adjustValue(colWidth, width);
        //   }
        // } else {
        for (int rowIndex = 0; rowIndex < calculateForRecordCount; rowIndex++) {
          dynamic value = dataChunk.data[rowIndex]![colIndex];

          if (value == null) {
            continue;
          }

          String formattedText = "$value"; // colDef.cellEditor.formatValue(value);
          double width = ParseUtil.getTextWidth(
              text: formattedText, style: tableModel.getTextStyle(), textScaleFactor: textScaleFactor);

          width *= 1.3; // Value is multiplied by 1.3 to make sure that the text is not cut off
          // because the calculated width is too small. Still not sure why, but it works.

          colWidth = adjustValue(colWidth, width);
        }
        // }

        tableSize.calculatedColumnWidths[showIndex] =
            adjustValue(tableSize.calculatedColumnWidths[showIndex], colWidth);

        tableSize.columnWidths[showIndex] = tableSize.calculatedColumnWidths[showIndex];
      }
    }

    dev.log("calculated ${tableSize.columnWidths}");

    if (tableModel.autoResize && tableSize.calculatedSize.width < availableWidth) {
      dev.log("redistribute ${tableSize.calculatedSize.width}");
      dev.log("redistribute ${tableSize.size.width}");

      tableSize.redistributeRemainingWidth(availableWidth - tableSize.calculatedSize.width);
      dev.log("after redis ${tableSize.size.width}");
    }

    return tableSize;
  }

  static double adjustValue(double currentWidth, double wantedWith) {
    if (wantedWith > currentWidth) {
      return math.min(math.max(wantedWith, TableSize.defaultMinWidth), TableSize.defaultMaxWidth);
    } else {
      return currentWidth;
    }
  }
}

/// Represents a table size
class TableSize {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The default minimum width of a column
  static double defaultMinWidth = 15;

  /// The default maximum width of a column
  static double defaultMaxWidth = 200;

  /// The default row height
  static double defaultRowHeight = 50.0;

  /// The default border width
  static double borderWidth = 1.0;
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The calculated size of the columns
  List<double> calculatedColumnWidths;

  /// The size of the columns
  List<double> columnWidths;

  /// The table header heigth
  double tableHeaderHeight;

  /// The individual row height
  double rowHeight;

  TableSize({
    List<double>? columnWidths,
    double? tableHeaderHeight,
    double? rowHeight,
  })  : calculatedColumnWidths = columnWidths ?? [],
        columnWidths = columnWidths ?? [],
        tableHeaderHeight = tableHeaderHeight ?? defaultRowHeight,
        rowHeight = rowHeight ?? defaultRowHeight;

  TableSize.initial(int columnCount)
      : calculatedColumnWidths = List.filled(columnCount, defaultMinWidth),
        columnWidths = List.filled(columnCount, defaultMinWidth),
        tableHeaderHeight = defaultRowHeight,
        rowHeight = defaultRowHeight;

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

  redistributeRemainingWidth(double pRemainingWidth) {
    double currentWidth = calculatedSize.width;

    for (int i = 0; i < columnWidths.length; i++) {
      double width = columnWidths[i];
      // Every width gets equal share of remaining width
      // Ignores max width, as we have to fill it!
      width += (width / currentWidth) * pRemainingWidth;

      columnWidths[i] = width;
    }
  }

  autoResizeTo(double pWidth) {
    double currentWidth = calculatedSize.width;

    for (int i = 0; i < columnWidths.length; i++) {
      double width = columnWidths[i];
      // Every width gets equal share of remaining width
      // Ignores max width, as we have to fill it!
      width = (width / currentWidth) * pWidth;

      columnWidths[i] = width;
    }
  }
}
