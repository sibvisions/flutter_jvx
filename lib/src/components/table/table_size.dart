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

import '../../../flutter_jvx.dart';
import '../../model/response/record_format.dart';
import '../../service/api/shared/fl_component_classname.dart';
import '../editor/cell_editor/i_cell_editor.dart';
import 'fl_table_cell.dart';

/// Represents a table size
class TableSize {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Standard cell paddings
  static const EdgeInsets paddingsDefault = EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0, bottom: 4.0);

  /// Small cell paddings.
  static const EdgeInsets paddingsSmall = EdgeInsets.only(left: 1.0, right: 1.0, top: 4.0, bottom: 4.0);

  /// The border width outside.
  double borderWidth;

  /// The border width between columns.
  double columnDividerWidth;

  /// The minimum width of a column
  double minColumnWidth;

  /// The maximum width of a column
  double maxColumnWidth;

  /// The temporary max column width
  double? _maxColumnWidth;

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

  /// The calculated size of the column headers
  Map<String, double> calculatedHeaderWidths = {};

  /// The size of the columns
  Map<String, double> columnWidths = {};

  /// The format size of the columns
  Map<String, double> columnFormatWidths = {};

  /// the sum of calculatedColumnWidths
  double sumCalculatedColumnWidth = -1;

  /// the sum of columnWidths
  double sumColumnWidth = -1;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  TableSize({
    this.borderWidth = JVxColors.BORDER_WIDTH_DEFAULT,
    this.columnDividerWidth = 1.0,
    this.minColumnWidth = 50,
    this.maxColumnWidth = 400,
    tableHeaderHeight,
    rowHeight,
    this.checkCellWidth = 55.0,
    this.imageCellWidth = 55.0,
    this.choiceCellWidth = 55.0,
    this.cellPaddings = paddingsDefault,
  }) : tableHeaderHeight = tableHeaderHeight ?? JVxColors.componentHeight() + 2,
       rowHeight = rowHeight ?? JVxColors.componentHeight() + 2;

  /// Always calculates the table size.
  TableSize.direct({
    this.borderWidth = JVxColors.BORDER_WIDTH_DEFAULT,
    this.columnDividerWidth = 1.0,
    this.minColumnWidth = 50,
    this.maxColumnWidth = 400,
    tableHeaderHeight,
    rowHeight,
    this.checkCellWidth = 55.0,
    this.imageCellWidth = 55.0,
    this.choiceCellWidth = 55.0,
    this.cellPaddings = paddingsDefault,
    required FlTableModel tableModel,
    required DataChunk dataChunk,
    required DalMetaData metaData,
    double? availableWidth,
  }) : tableHeaderHeight = tableHeaderHeight ?? JVxColors.componentHeight() + 2,
       rowHeight = rowHeight ?? JVxColors.componentHeight() + 2
  {
    calculateTableSize(tableModel: tableModel, metaData: metaData, availableWidth: availableWidth, dataChunk: dataChunk);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void calculateTableSize({
    required FlTableModel tableModel,
    required DataChunk dataChunk,
    required DalMetaData metaData,
    int rowsToCalculate = 10,
    double? availableWidth,
    double scaling = 1.0,
  }) {
    calculatedColumnWidths.clear();
    calculatedHeaderWidths.clear();
    columnFormatWidths.clear();

    availableWidth = math.max((availableWidth ?? 0.0) - (borderWidth * 2), 0);

    //it's not nice if a column is larger than the available space of the whole table,
    //so adjust the max column width
    if (maxColumnWidth > 0  && maxColumnWidth > availableWidth ) {

      _maxColumnWidth = availableWidth - 20;
    }
    else {
      _maxColumnWidth = maxColumnWidth;
    }

    ApplicationMetaDataResponse? appMetaData = IUiService().applicationMetaData.value;

    String mandatoryMark = "";

    if (appMetaData != null) {
      if (appMetaData.mandatoryMarkVisible) {
        mandatoryMark = " ${appMetaData.mandatoryMark ?? "*"}";
      }
    }
    else {
      mandatoryMark = " *";
    }

    // No data and no meta data so there cant be fixed sizes.
    TextStyle textStyle = tableModel.createTextStyle();

    // How far you can calculate with the data we currently have.
    for (int i = 0; i < tableModel.columnNames.length; i++) {
      String columnName = tableModel.columnNames[i];
      String columnLabel = tableModel.columnLabels[i];

      //Column headers get a * if they are mandatory
      if (metaData.columnDefinitions.byName(columnName)?.nullable != true) {
        columnLabel = "$columnLabel$mandatoryMark";
      }

      double calculatedHeaderWidth = _calculateTextWidth(textStyle.copyWith(fontWeight: FontWeight.bold), columnLabel);

      //Sort arrow and direction text
      if (metaData.sortDefinitions?.byName(columnName)?.mode != null) {
        calculatedHeaderWidth += 21;
      }

      double adjustedCalculatedHeaderWidth = _adjustColumnWidth(0, calculatedHeaderWidth);

      //save calculated header width (min/max check)
      calculatedHeaderWidths[columnName] = adjustedCalculatedHeaderWidth;

      //header-width is start value for column width calculation
      calculatedColumnWidths[columnName] = adjustedCalculatedHeaderWidth;

      int calculateUntilRow = math.min(rowsToCalculate, dataChunk.data.length);

      ColumnDefinition? columnDefinition = metaData.columnDefinitions.byName(columnName);

      // If there is no column definition found for this column, we can't calculate the width based on data
      if (columnDefinition != null) {
        if (columnDefinition.width != null) {
          //width set for column
          if (columnDefinition.cellEditorClassName == FlCellEditorClassname.CHECK_BOX_CELL_EDITOR) {
            calculatedColumnWidths[columnName] = math.max(columnDefinition.width! * scaling, checkCellWidth);
          } else if (columnDefinition.cellEditorClassName == FlCellEditorClassname.CHOICE_CELL_EDITOR ) {
            calculatedColumnWidths[columnName] = math.max(columnDefinition.width! * scaling, choiceCellWidth);
          } else if (columnDefinition.cellEditorClassName == FlCellEditorClassname.IMAGE_VIEWER) {
            calculatedColumnWidths[columnName] = math.max(columnDefinition.width! * scaling, imageCellWidth);
          } else {
            calculatedColumnWidths[columnName] = columnDefinition.width! * scaling;
          }
        } else {
          ICellEditor cellEditor = _createCellEditor(columnDefinition, metaData);
          double? calculatedWidth;

          if (cellEditor.allowedInTable) {
            if (cellEditor is FlCheckBoxCellEditor) {
              calculatedWidth = checkCellWidth;
            } else if (cellEditor is FlChoiceCellEditor) {
              calculatedWidth = choiceCellWidth;
            } else if (cellEditor is FlImageCellEditor) {
              calculatedWidth = imageCellWidth;
            }
          }

          if (calculatedWidth == null) {
            // Get all rows before [calculateUntilRow]
            List<dynamic> dataRows = [];
            List<CellFormat?> dataFormats = [];
            List<dynamic> dataForColumn = [];

            int colIndex = dataChunk.columnDefinitions.indexByName(columnName);

            for (int i = 0; i < calculateUntilRow; i++) {
              dataRows.add(dataChunk.data[i]);
              dataFormats.add(dataChunk.recordFormats?[tableModel.name]?.getCellFormat(i, colIndex));

              // we need the values for the column
              dataForColumn.add(dataChunk.data[i]![colIndex]);
            }

            calculatedWidth = _calculateDataWidth(columnName, dataRows, dataFormats, dataForColumn, cellEditor, textStyle);
          }

          cellEditor.dispose();

          calculatedColumnWidths[columnName] = _adjustColumnWidth(calculatedColumnWidths[columnName]!, calculatedWidth);
        }
      }
    }

    sumCalculatedColumnWidth = 0;

    // Remove any negative widths.
    for (String key in calculatedColumnWidths.keys) {
      double width = calculatedColumnWidths[key]!;

      calculatedColumnWidths[key] = math.max(0, width);

      sumCalculatedColumnWidth += width;
    }

    columnWidths.clear();
    columnWidths.addAll(calculatedColumnWidths);

    double remainingWidth = availableWidth - sumCalculatedColumnWidth;

    // Redistribute the remaining width. AutoSize forces all columns inside the table.
    if (remainingWidth > 0) {
      //add some space to other columns (fill the empty space)
      divideOut(tableModel, metaData, remainingWidth, availableWidth);
    } else if (tableModel.autoResize && remainingWidth < 0) {
      //shrink as good as possible
      autoSize(tableModel, metaData, remainingWidth, availableWidth);
    } else if (!tableModel.autoResize && remainingWidth < 0 && remainingWidth > -8) {
      //if the current width is only 8px wider than the table, try to fit exactly
      autoSize(tableModel, metaData, remainingWidth, availableWidth);
    }

    sumColumnWidth = columnWidths.values.sum;
  }

  ///Adds the remaining width to the available columns, if not set to fixed width.
  void divideOut(FlTableModel tableModel, DalMetaData metaData, double width, double availableWidth) {

    List<String> divideOutColumnNames = [];

    List<String> noWidth = [];
    List<String> withWidth = [];
    List<String> noWidthText = [];
    List<String> withWidthText = [];
    List<String> noWidthLink = [];
    List<String> withWidthLink = [];
    List<String> noWidthNumber = [];
    List<String> withWidthNumber = [];
    List<String> noWidthDate = [];
    List<String> withWidthDate = [];

    for (int i = 0; i < tableModel.columnNames.length; i++) {
      String columnName = tableModel.columnNames[i];

      ColumnDefinition? columnDefinition = metaData.columnDefinitions.byName(columnName);

      if (columnDefinition != null) {
        if (columnDefinition.width == null) {
          if (columnDefinition.cellEditorClassName == FlCellEditorClassname.TEXT_CELL_EDITOR) {
            noWidthText.add(columnName);
          } else if (columnDefinition.cellEditorClassName == FlCellEditorClassname.LINKED_CELL_EDITOR) {
            noWidthLink.add(columnName);
          } else if (columnDefinition.cellEditorClassName == FlCellEditorClassname.NUMBER_CELL_EDITOR) {
            noWidthNumber.add(columnName);
          } else if (columnDefinition.cellEditorClassName == FlCellEditorClassname.DATE_CELL_EDITOR) {
            noWidthDate.add(columnName);
          }else {
            noWidth.add(columnName);
          }
        }
        else {
          if (columnDefinition.cellEditorClassName == FlCellEditorClassname.TEXT_CELL_EDITOR) {
            withWidthText.add(columnName);
          } else if (columnDefinition.cellEditorClassName == FlCellEditorClassname.LINKED_CELL_EDITOR) {
            withWidthLink.add(columnName);
          } else if (columnDefinition.cellEditorClassName == FlCellEditorClassname.NUMBER_CELL_EDITOR) {
            withWidthNumber.add(columnName);
          } else if (columnDefinition.cellEditorClassName == FlCellEditorClassname.DATE_CELL_EDITOR) {
            withWidthDate.add(columnName);
          }else {
            withWidth.add(columnName);
          }
        }
      }
    }

    divideOutColumnNames.addAll(noWidthText);

    if (divideOutColumnNames.length < 3) { divideOutColumnNames.addAll(noWidthLink); }
    if (divideOutColumnNames.length < 5) { divideOutColumnNames.addAll(noWidthNumber); }
    if (divideOutColumnNames.isEmpty)    { divideOutColumnNames.addAll(noWidthDate); }
    if (divideOutColumnNames.length < 3) { divideOutColumnNames.addAll(withWidthLink); }
    if (divideOutColumnNames.length < 5) { divideOutColumnNames.addAll(withWidthNumber); }
    if (divideOutColumnNames.isEmpty)    { divideOutColumnNames.addAll(withWidthDate); }
    if (divideOutColumnNames.isEmpty)    { divideOutColumnNames.addAll(noWidth); }
    if (divideOutColumnNames.isEmpty)    { divideOutColumnNames.addAll(withWidth); }

    if (divideOutColumnNames.isNotEmpty) {
      double part = width / divideOutColumnNames.length;

      double sumParts = part.toPrecision(2) * divideOutColumnNames.length;

      double rest = width - sumParts;

      for (int i = 0; i < divideOutColumnNames.length; i++) {
        columnWidths[divideOutColumnNames[i]] = columnWidths[divideOutColumnNames[i]]! + part;
      }

      columnWidths[divideOutColumnNames.last] = columnWidths[divideOutColumnNames.last]! + rest;
    }
  }

  ///Tries to fit all columns in [availableWidth]
  void autoSize(FlTableModel tableModel, DalMetaData metaData, double width, double availableWidth) {
    double calculated10th = sumCalculatedColumnWidth / 10;

    List<String> divideOutColumnNames = [];

    List<String> noWidth = [];
    List<String> withWidth = [];
    List<String> noWidthText = [];
    List<String> withWidthText = [];
    List<String> noWidthLink = [];
    List<String> withWidthLink = [];
    List<String> noWidthNumber = [];
    List<String> withWidthNumber = [];
    List<String> withWidthBox = [];

    for (int i = 0; i < tableModel.columnNames.length; i++) {
      String columnName = tableModel.columnNames[i];

      ColumnDefinition? columnDefinition = metaData.columnDefinitions.byName(columnName);

      if (columnDefinition != null) {
        if (columnDefinition.width == null) {
          if (columnDefinition.cellEditorClassName == FlCellEditorClassname.TEXT_CELL_EDITOR) {
            noWidthText.add(columnName);
          } else if (columnDefinition.cellEditorClassName == FlCellEditorClassname.LINKED_CELL_EDITOR) {
            noWidthLink.add(columnName);
          } else if (columnDefinition.cellEditorClassName == FlCellEditorClassname.NUMBER_CELL_EDITOR) {
            noWidthNumber.add(columnName);
          } else if (columnDefinition.cellEditorClassName == FlCellEditorClassname.DATE_CELL_EDITOR) {
            //ignore
          } else {
            noWidth.add(columnName);
          }
        }
        else {
          if (columnDefinition.cellEditorClassName == FlCellEditorClassname.TEXT_CELL_EDITOR) {
            withWidthText.add(columnName);
          } else if (columnDefinition.cellEditorClassName == FlCellEditorClassname.LINKED_CELL_EDITOR) {
            withWidthLink.add(columnName);
          } else if (columnDefinition.cellEditorClassName == FlCellEditorClassname.NUMBER_CELL_EDITOR) {
            withWidthNumber.add(columnName);
          } else if (columnDefinition.cellEditorClassName == FlCellEditorClassname.DATE_CELL_EDITOR) {
            //ignore
          } else if (columnDefinition.cellEditorClassName == FlCellEditorClassname.CHOICE_CELL_EDITOR
                     || columnDefinition.cellEditorClassName == FlCellEditorClassname.CHECK_BOX_CELL_EDITOR) {
            withWidthBox.add(columnName);
          } else {
            withWidth.add(columnName);
          }
        }
      }
    }

    //calculated width is only max. 1/10 more than the available width -> make columns smaller
    if (availableWidth + calculated10th >= sumCalculatedColumnWidth) {
      divideOutColumnNames.addAll(noWidthText);

      if (divideOutColumnNames.length < 3) { divideOutColumnNames.addAll(noWidthLink); }
      if (divideOutColumnNames.length < 5) { divideOutColumnNames.addAll(noWidthNumber); }
      if (divideOutColumnNames.length < 3) { divideOutColumnNames.addAll(withWidthLink); }
      if (divideOutColumnNames.length < 5) { divideOutColumnNames.addAll(withWidthNumber); }
      if (divideOutColumnNames.isEmpty)    { divideOutColumnNames.addAll(noWidth); }
      if (divideOutColumnNames.isEmpty)    { divideOutColumnNames.addAll(withWidth); }

      //special mode to shrink the table but don't change the width of "all" columns
      //only 10px difference -> try to find a columns which are already large and make them smaller
      if (!tableModel.autoResize && width.abs() < 10) {
        double part = width / divideOutColumnNames.length;

        List<String> longColumns = [];
        List<String> extraLongColumns = [];

        String? longestColumn;
        double maxDiff = 0;

        double subtracted = 0;
        double diff;

        //find columns which are "long" enough after subtraction. The header should be fully visible
        for (int i = 0; i < divideOutColumnNames.length; i++) {
          if (columnWidths[divideOutColumnNames[i]]! + part > calculatedHeaderWidths[divideOutColumnNames[i]]!) {
            longColumns.add(divideOutColumnNames[i]);

            subtracted += part;
          }

          if (columnWidths[divideOutColumnNames[i]]! - 10 > calculatedHeaderWidths[divideOutColumnNames[i]]!) {
            extraLongColumns.add(divideOutColumnNames[i]);
          }

          diff = columnWidths[divideOutColumnNames[i]]! - calculatedHeaderWidths[divideOutColumnNames[i]]!;

          //find the column with most space between header label and width
          if (diff > maxDiff) {
            maxDiff = diff;
            longestColumn = divideOutColumnNames[i];
          }
        }

        double rest = width - subtracted;

        //if we have a rest, it will be negative, for sure
        //if there's a column with enough space left -> update width
        if (rest < 0 && rest > -maxDiff) {
          for (int i = 0; i < longColumns.length; i++) {
            columnWidths[longColumns[i]] = columnWidths[longColumns[i]]! + part;
          }

          columnWidths[longestColumn!] = columnWidths[longestColumn]! + rest;

          return;
        }
        else if (extraLongColumns.isNotEmpty) {
          //only use extra long column names to update width
          divideOutColumnNames.clear();
          divideOutColumnNames.addAll(extraLongColumns);
        }
      }

      double part = width / divideOutColumnNames.length;

      double sumParts = part.toPrecision(2) * divideOutColumnNames.length;

      double rest = width - sumParts;

      for (int i = 0; i < divideOutColumnNames.length; i++) {
        columnWidths[divideOutColumnNames[i]] = columnWidths[divideOutColumnNames[i]]! + part;
      }

      columnWidths[divideOutColumnNames.last] = columnWidths[divideOutColumnNames.last]! + rest;
    }
    else {
      //try to use "special" columns with fixed size without width adjustment

      divideOutColumnNames.addAll(withWidthBox);

      double fixedSize = 0;

      //if all columns are fixed -> ignore fixed size columns
      if (divideOutColumnNames.length < columnWidths.length) {

        for (int i = 0; i < divideOutColumnNames.length; i++) {
          fixedSize += columnWidths[divideOutColumnNames[i]]!;
        }
      }
      else {
        divideOutColumnNames.clear();
      }

      int columnsLeft = tableModel.columnNames.length - divideOutColumnNames.length;

      double part = (availableWidth - fixedSize) / columnsLeft;

      double maybeWidth;
      double tooLargeSum = 0;

      Map<String, double> columnsTooLarge = {};

      //Get all columns which are larger than the maybe width, based on the cell format
      for (int i = 0; i < columnWidths.length; i++) {
        if (!divideOutColumnNames.contains(tableModel.columnNames[i])) {
          maybeWidth = FlTableCell.clearIconSize + FlTableCell.iconSize +
                       paddingsSmall.left + paddingsSmall.right + (columnFormatWidths[tableModel.columnNames[i]] ?? 0);

          if (maybeWidth > part) {
            columnsTooLarge[tableModel.columnNames[i]] = maybeWidth;

            tooLargeSum += maybeWidth - part;
          }
        }
      }

      // divide out width for all available columns

      double sumParts = part.toPrecision(2) * columnsLeft;

      double rest = availableWidth - fixedSize - sumParts;

      List<String> resizableColumns = [];

      String? lastNotFixed;
      for (int i = 0; i < columnWidths.length; i++) {

        if (!divideOutColumnNames.contains(tableModel.columnNames[i])) {
          columnWidths[tableModel.columnNames[i]] = part;

          lastNotFixed = tableModel.columnNames[i];

          if (!columnsTooLarge.containsKey(tableModel.columnNames[i])) {
            //collect all columns which are not too large and can be resized
            //also possible that such columns are too small after resizing
            resizableColumns.add(tableModel.columnNames[i]);
          }
        }
      }

      lastNotFixed ??= tableModel.columnNames.last;

      columnWidths[lastNotFixed] = columnWidths[lastNotFixed]! + rest;

      if (resizableColumns.isNotEmpty) {
        //another adjustment for too large columns, based on the cell format
        part = tooLargeSum / resizableColumns.length;

        sumParts = part.toPrecision(2) * resizableColumns.length;

        rest = tooLargeSum - sumParts;

        //make too large columns larger than the resizable columns
        columnsTooLarge.forEach((name, width) => columnWidths[name] = width);

        //make resizable columns smaller - maybe too small
        for (int i = 0; i < resizableColumns.length; i++) {
          columnWidths[resizableColumns[i]] = columnWidths[resizableColumns[i]]! - part;
        }

        columnWidths[resizableColumns.last] = columnWidths[resizableColumns.last]! + rest;
      }
    }
  }

  double _calculateDataWidth(
    String columnName,
    List<dynamic> dataRows,
    List<CellFormat?> dataFormats,
    List<dynamic> dataColumn,
    ICellEditor cellEditor,
    TextStyle pTextStyle,
  ) {
    double columnWidth = 0.0;

    for (int i = 0; i < dataColumn.length; i++) {
      dynamic value = dataColumn[i];

      if (value != null) {
        if (cellEditor is FlLinkedCellEditor) {
          cellEditor.setValue((value, dataRows[i]));
        }
        String formattedText = cellEditor.formatValue(value);

        CellFormat? format = dataFormats[i];

        TextStyle textStyle = pTextStyle;

        if (format != null && format.font != null)   {
          //use cell format instead of standard text style
          textStyle = TextStyle(
            color: format.foreground ?? pTextStyle.color,
            fontSize: format.font?.fontSize.toDouble() ?? pTextStyle.fontSize,
            fontStyle: format.font != null ? FontStyle.italic : pTextStyle.fontStyle,
            fontWeight: format.font != null ? FontWeight.bold : pTextStyle.fontWeight,
            fontFamily: format.font?.fontName ?? pTextStyle.fontFamily,
            overflow: TextOverflow.ellipsis,
          );
        }

        double rowWidth = _calculateTextWidth(textStyle, formattedText);

        if (format != null) {
          double formatWidth = format.leftIndent?.toDouble() ?? 0;

          if (format.imageString != null) {
            List<String> split = format.imageString!.split(",");

            if (split.length >= 3) {
              formatWidth += double.tryParse(split[1]) ?? 0;
            }

            //if an image is defined -> add gap because it's added as padding
            formatWidth += FlTableCell.formatImageGap;
          }

          rowWidth += formatWidth;

          columnFormatWidths[columnName] = math.max(formatWidth, columnFormatWidths[columnName] ?? 0);
        }
        else {
          columnFormatWidths[columnName] = 0;
        }

        columnWidth = _adjustColumnWidth(columnWidth, rowWidth);
      }
    }

    columnWidth = _adjustColumnWidth(columnWidth, columnWidth + FlTableCell.getContentPadding(cellEditor));

    return columnWidth;
  }

  ///Calculates text width with given style and table settings like divider and paddings.
  double _calculateTextWidth(
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

  double _adjustColumnWidth(double oldWidth, double newWidth) {
    if (newWidth > oldWidth) {
      //new width between min and max column width
      return math.min(math.max(newWidth, minColumnWidth), _maxColumnWidth ?? maxColumnWidth);
    } else {
      return oldWidth;
    }
  }

  ICellEditor _createCellEditor(ColumnDefinition colDef, DalMetaData metaData) {
    return ICellEditor.getCellEditor(
      cellEditorJson: colDef.cellEditorJson,
      name: "",
      dataProvider: metaData.dataProvider,
      columnName: colDef.name,
      isInTable: true,
    );
  }

}
