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

import 'dart:math' as Math;

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

import '../../../flutter_jvx.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/data/column_definition.dart';
import '../../model/data/data_book.dart';
import '../../model/data/subscriptions/data_chunk.dart';
import '../../model/response/record_format.dart';
import '../../service/api/shared/fl_component_classname.dart';
import '../../util/extensions/double_extensions.dart';
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

  /// the sum of calculatedColumnWidths
  double sumCalculatedColumnWidth = -1;

  /// the sum of columnWidths
  double sumColumnWidth = -1;

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
    calculateTableSize(tableModel: tableModel, metaData: metaData, availableWidth: availableWidth, dataChunk: dataChunk);
  }

/*
  /// The width every column would like to have. Does not include the Border!
  double get calculatedWidth {
    return calculatedColumnWidths.values.sum;
  }

  /// The width every column actually gets allotted. Does not include the Border!
  double get width {
    return columnWidths.values.sum;
  }
*/
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  calculateTableSize({
    required FlTableModel tableModel,
    required DataChunk dataChunk,
    required DalMetaData metaData,
    int rowsToCalculate = 10,
    double? availableWidth,
    double scaling = 1.0,
  }) {
    calculatedColumnWidths.clear();

    availableWidth = Math.max((availableWidth ?? 0.0) - (borderWidth * 2), 0);

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
      if (metaData.columnDefinition(columnName)?.nullable != true) {
        columnLabel = "$columnLabel$mandatoryMark";
      }

      double calculatedHeaderWidth = _calculateTextWidth(textStyle.copyWith(fontWeight: FontWeight.bold), columnLabel);

      //Sort arrow and direction text
      if (metaData.sortDefinition(columnName)?.mode != null) {
        calculatedHeaderWidth += 21;
      }

      //header-width is start value for column width calculation
      calculatedColumnWidths[columnName] = _adjustColumnWidth(0, calculatedHeaderWidth);

      int calculateUntilRow = Math.min(rowsToCalculate, dataChunk.data.length);

      ColumnDefinition? columnDefinition = dataChunk.columnDefinition(columnName);

      // If there is no column definition found for this column, we can't calculate the width based on data
      if (columnDefinition != null) {
        if (columnDefinition.width != null) {
          //width set for column
          if (columnDefinition.cellEditorClassName == FlCellEditorClassname.CHECK_BOX_CELL_EDITOR) {
            calculatedColumnWidths[columnName] = Math.max(columnDefinition.width! * scaling, checkCellWidth);
          } else if (columnDefinition.cellEditorClassName == FlCellEditorClassname.CHOICE_CELL_EDITOR ) {
            calculatedColumnWidths[columnName] = Math.max(columnDefinition.width! * scaling, choiceCellWidth);
          } else if (columnDefinition.cellEditorClassName == FlCellEditorClassname.IMAGE_VIEWER) {
            calculatedColumnWidths[columnName] = Math.max(columnDefinition.width! * scaling, imageCellWidth);
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

            int colIndex = dataChunk.columnDefinitionIndex(columnName);

            for (int i = 0; i < calculateUntilRow; i++) {
              dataRows.add(dataChunk.data[i]);
              dataFormats.add(dataChunk.recordFormats?[tableModel.name]?.getCellFormat(i, colIndex));

              // we need the values for the column
              dataForColumn.add(dataChunk.data[i]![colIndex]);
            }

            calculatedWidth = _calculateDataWidth(dataRows, dataFormats, dataForColumn, cellEditor, textStyle);
          }

          cellEditor.dispose();

          calculatedColumnWidths[columnName] = _adjustColumnWidth(calculatedColumnWidths[columnName]!, calculatedWidth!);
        }
      }
    }

    sumCalculatedColumnWidth = 0;

    // Remove any negative widths.
    for (String key in calculatedColumnWidths.keys) {
      double width = calculatedColumnWidths[key]!;

      calculatedColumnWidths[key] = Math.max(0, width);

      sumCalculatedColumnWidth += width;
    }

    columnWidths.clear();
    columnWidths.addAll(calculatedColumnWidths);

    double remainingWidth = availableWidth - sumCalculatedColumnWidth;

    // Redistribute the remaining width. AutoSize forces all columns inside the table.
    if (remainingWidth > 0.0) {
      //add some space to other columns
      divideOut(tableModel, dataChunk, remainingWidth, availableWidth);
    } else if ((tableModel.autoResize || remainingWidth >= -10.0) && remainingWidth < 0.0) {
/*
      double width = pAvailableWidth / columnWidths.length;
print(width);
print(columnWidths.length);
      for (String columnName in columnWidths.keys) {
        double columnWidth = columnWidths[columnName]!;

        print(columnName);
        columnWidths[columnName] = width;
//        calculatedColumnWidths[columnName] = width;
      }

//      columnWidths["PHONE"] = 30.2;

*/

//print(_getColumnsToRedistribute(dataChunk));
/*
      // '30' is only there to stop if infinite loop happens.
      for (int i = 0; remainingWidth < 0.0 && i < 30; i++) {
        _redistributeRemainingWidth(_getColumnsToRedistribute(dataChunk), remainingWidth);

        remainingWidth = availableWidth - columnWidths.values.sum;
      }
*/

    }
    sumColumnWidth = columnWidths.values.sum;
  }

  void divideOut(FlTableModel tableModel, DataChunk dataChunk, double width, double availableWidth) {

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

      ColumnDefinition? columnDefinition = dataChunk.columnDefinition(columnName);

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

    if (divideOutColumnNames.length < 3) {
      divideOutColumnNames.addAll(noWidthLink);
    }

    if (divideOutColumnNames.length < 5) {
      divideOutColumnNames.addAll(noWidthNumber);
    }

    if (divideOutColumnNames.isEmpty) {
      divideOutColumnNames.addAll(noWidthDate);
    }

    if (divideOutColumnNames.length < 3) {
      divideOutColumnNames.addAll(withWidthLink);
    }

    if (divideOutColumnNames.length < 5) {
      divideOutColumnNames.addAll(withWidthNumber);
    }

    if (divideOutColumnNames.isEmpty) {
      divideOutColumnNames.addAll(withWidthDate);
    }

    if (divideOutColumnNames.isEmpty) {
      divideOutColumnNames.addAll(noWidth);
    }

    if (divideOutColumnNames.isEmpty) {
      divideOutColumnNames.addAll(withWidth);
    }

    double part = width / divideOutColumnNames.length;

    double sumParts = part.toPrecision(2) * divideOutColumnNames.length;

    double rest = width - sumParts;

    for (int i = 0; i < divideOutColumnNames.length - 1; i++) {
      columnWidths[divideOutColumnNames[i]] = columnWidths[divideOutColumnNames[i]]! + part;
    }

    columnWidths[divideOutColumnNames.last] = columnWidths[divideOutColumnNames.last]! + part + rest;
  }

//  List<int> _getColumnsByDataType(t)

  double _calculateDataWidth(
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

        if (format != null && format!.font != null)   {
          //use cell format instead of standard text style
          textStyle = TextStyle(
            color: format!.foreground ?? pTextStyle.color,
            fontSize: format!.font?.fontSize?.toDouble() ?? pTextStyle.fontSize,
            fontStyle: format!.font != null ? FontStyle.italic : pTextStyle.fontStyle,
            fontWeight: format!.font != null ? FontWeight.bold : pTextStyle.fontWeight,
            fontFamily: format!.font?.fontName ?? pTextStyle.fontFamily,
            overflow: TextOverflow.ellipsis,
          );
        }

        double rowWidth = _calculateTextWidth(textStyle, formattedText);

        if (format != null) {
          rowWidth += format.leftIndent ?? 0;

          if (format!.imageString != null) {
            List<String> split = format!.imageString!.split(",");

            if (split.length >= 3) {
              rowWidth += double.tryParse(split[1]) ?? 0;
            }
          }
        }

        columnWidth = _adjustColumnWidth(columnWidth, rowWidth);
      }
    }

    columnWidth = _adjustColumnWidth(columnWidth, columnWidth + FlTableCell.getContentPadding(cellEditor));

    return columnWidth;
  }

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
/*
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
*/

  double _adjustColumnWidth(double oldWidth, double newWidth) {
    if (newWidth > oldWidth) {
      //new width between min and max column width
      return Math.min(Math.max(newWidth, minColumnWidth), maxColumnWidth);
    } else {
      return oldWidth;
    }
  }

  ///no operation
  static void _noop(dynamic object) {}

  ICellEditor _createCellEditor(ColumnDefinition colDef, DalMetaData metaData) {
    return ICellEditor.getCellEditor(
      pName: "",
      pCellEditorJson: colDef.cellEditorJson,
      columnName: colDef.name,
      dataProvider: metaData.dataProvider,
      onChange: _noop,
      onEndEditing: _noop,
      onFocusChanged: _noop,
      isInTable: true,
    );
  }
/*
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

 */
}
