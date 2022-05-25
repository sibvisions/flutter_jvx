import 'dart:math';

import 'package:flutter_client/src/model/component/table/fl_table_model.dart';
import 'package:flutter_client/src/model/data/column_definition.dart';
import 'package:flutter_client/src/model/data/subscriptions/data_chunk.dart';
import 'package:flutter_client/util/parse_util.dart';

class ColumnSizeCalculator {
  static double defaultMinWidth = 15;
  static double defaultMaxWidth = 200;

  static TableSize calculateTableSize({
    required FlTableModel tableModel,
    DataChunk? dataChunk,
    double textScaleFactor = 1.0,
    int calculateForRecordCount = 10,
  }) {
    TableSize tableSize = TableSize();

    List<String> columnHeaders = tableModel.columnLabels ?? tableModel.columnNames;

    for (String columnHeader in columnHeaders) {
      tableSize.columnWidths.add(
        adjustValue(
          defaultMinWidth,
          ParseUtil.getTextWidth(
            text: columnHeader,
            style: tableModel.getTextStyle(),
            textScaleFactor: textScaleFactor,
          ),
        ),
      );
    }

    // get preferred data widths
    if (dataChunk != null) {
      calculateForRecordCount = min(dataChunk.data.length, calculateForRecordCount);

      int colIndex = -1;
      int showIndex = -1;
      for (ColumnDefinition colDef in dataChunk.columnDefinitions) {
        colIndex++;

        if (!tableModel.columnNames.contains(colDef.name)) {
          continue; //Not to be meassured
        }

        showIndex++;

        double colWidth = defaultMinWidth;

        if (colDef.width != null) {
          colWidth = adjustValue(colWidth, colDef.width!);
        }

        if (colDef.cellEditor.model.directCellEditor) {
          // Calculate width of this column with formattings of this cell editor
          double? width = colDef.cellEditor.getWidgetModel().preferredSize?.width;
          if (width != null) {
            colWidth = adjustValue(colWidth, width);
          }
        } else {
          for (int rowIndex = 0; rowIndex < calculateForRecordCount; rowIndex++) {
            if (defaultMinWidth < colWidth && colWidth < defaultMaxWidth) {
              dynamic value = dataChunk.data[rowIndex]![colIndex];

              if (value == null) {
                continue;
              }

              String formattedText = colDef.cellEditor.formatValue(value);
              double width = ParseUtil.getTextWidth(
                  text: formattedText, style: tableModel.getTextStyle(), textScaleFactor: textScaleFactor);

              colWidth = adjustValue(colWidth, width);
            }
          }
        }

        tableSize.columnWidths[showIndex] = adjustValue(tableSize.columnWidths[showIndex], colWidth);
      }
    }

    return tableSize;
  }

  // static double getPreferredTableHeight(SoComponentData componentData, List<String> columnLabels, TextStyle textStyle,
  //     bool tableHeaderVisible, double textScaleFactor,
  //     [double headerPadding = 13, double itemPadding = 8, double borderWidth = 1, int calculateForRecordCount = 1]) {
  //   double headerHeight = 0;
  //   double itemHeight = 0;
  //   int recordCount = calculateForRecordCount;

  //   if (columnLabels.isNotEmpty) {
  //     double textHeight = TextUtils.getTextHeight(columnLabels[0], textStyle, textScaleFactor);
  //     if (tableHeaderVisible) headerHeight = textHeight + headerPadding;
  //     itemHeight = textHeight + itemPadding;
  //   }

  //   if (componentData.data?.records != null && componentData.data!.records.length > calculateForRecordCount) {
  //     recordCount = componentData.data!.records.length;
  //   }

  //   return headerHeight + (itemHeight * recordCount) + (borderWidth * 2);
  // }

  // static void _calculateAutoSizeColumnWidths(List<TableColumnSize> columns, double containerWidth) {
  //   double sumFixedColumnWidth = _getFixedColumnWidthSum(columns);
  //   double sumFlexColumnWidth = _getFlexColumnWidthSum(columns);
  //   bool moreFlexAvailable = sumFlexColumnWidth > 0;
  //   double flexReduceFactor = sumFlexColumnWidth / (containerWidth - sumFixedColumnWidth);

  //   while (moreFlexAvailable &&
  //       ((containerWidth < getColumnWidthSum(columns) && flexReduceFactor > 1.0) ||
  //           (containerWidth > getColumnWidthSum(columns) && flexReduceFactor > 0.0))) {
  //     moreFlexAvailable = false;

  //     for (int i = 0; i < columns.length; i++) {
  //       TableColumnSize c = columns[i];
  //       if (c.isFlexColumn) {
  //         c.reducePreferredWidth(flexReduceFactor);

  //         if (c.isFlexColumn) moreFlexAvailable = true;
  //       }
  //     }

  //     if (moreFlexAvailable) {
  //       sumFixedColumnWidth = _getFixedColumnWidthSum(columns);
  //       sumFlexColumnWidth = _getFlexColumnWidthSum(columns);
  //       flexReduceFactor = sumFlexColumnWidth / (containerWidth - sumFixedColumnWidth);
  //     }
  //   }
  // }

  static double adjustValue(double currentWidth, double wantedWith) {
    if (wantedWith > currentWidth) {
      return min(max(wantedWith, defaultMinWidth), defaultMaxWidth);
    } else {
      return currentWidth;
    }
  }
}

class TableSize {
  List<double> columnWidths;
  double tableHeaderHeight;
  double rowHeight;

  TableSize({
    List<double>? columnWidths,
    double? tableHeaderHeight,
    double? rowHeight,
  })  : columnWidths = columnWidths ?? [],
        tableHeaderHeight = tableHeaderHeight ?? 20.0,
        rowHeight = rowHeight ?? 20.0;

  TableSize.initial(int columnCount)
      : columnWidths = List.filled(columnCount, ColumnSizeCalculator.defaultMinWidth),
        tableHeaderHeight = 20.0,
        rowHeight = 20.0;

  double getTableSize(FlTableModel pModel) {
    double tableWidth = 0;
    for (int i = 0; i < columnWidths.length; i++) {
      tableWidth += columnWidths[i];
    }
    return tableWidth;
  }
}
