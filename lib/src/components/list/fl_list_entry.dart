/*
 * Copyright 2025 SIB Visions GmbH
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

import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:json_dynamic_widget/json_dynamic_widget.dart';

import '../../../flutter_jvx.dart';
import '../../model/layout/alignments.dart';
import '../../model/response/record_format.dart';
import '../../service/api/shared/fl_component_classname.dart';
import '../../util/column_list.dart';
import '../../util/i_types.dart';
import '../editor/cell_editor/i_cell_editor.dart';
import '../table/fl_table_cell.dart';
import 'list_image_builder.dart';

typedef DismissedCallback = void Function(int index);

class FlListEntry extends FlStatelessWidget<FlTableModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The colum definitions to build
  final ColumnList columnDefinitions;

  /// The value of the cell
  final List<dynamic> values;

  /// The index of the row this column is in
  final int index;

  /// If this row is selected
  final bool isSelected;

  /// If vertical centered
  final MainAxisAlignment mainAxisAlignment;

  /// The record formats
  final RecordFormat? recordFormat;

  /// custom card template as json
  final String? template;

  /// the column separators
  final List<String>? columnSeparator;

  /// column count per row, from [columnDefinitions]
  final Map<int, int>? columnsPerRow;

  /// the cell editors
  final Map<String, ICellEditor> cellEditors;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlListEntry({super.key,
    required super.model,
    required this.columnDefinitions,
    required this.cellEditors,
    required this.values,
    required this.index,
    required this.isSelected,
    this.recordFormat,
    this.template,
    this.columnsPerRow,
    this.columnSeparator,
    mainAxisAlignment}) : mainAxisAlignment = mainAxisAlignment ?? MainAxisAlignment.center;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    Widget? card;

    if (template != null) {
      card = _fromTemplate(
        context,
        template!,
      );
    }

    return card ?? _defaultEntry(context);
  }

  Widget? _fromTemplate(BuildContext context, String template) {
    String? jsonTemplate;

    String tplUrl = template;
    if (tplUrl.startsWith("/")) {
      tplUrl = tplUrl.substring(1);
    }

    if (!kIsWeb) {
      String? appVersion = IConfigService().version.value;

      if (appVersion != null) {
        IFileManager fileManager = IConfigService().getFileManager();

        String path = fileManager.getAppSpecificPath(
          "${IFileManager.TEMPLATES_PATH}/$tplUrl",
          appId: IConfigService().currentApp.value!,
          version: appVersion,
        );

        File? file = fileManager.getFileSync(path);

        if (file?.existsSync() == true) {
          jsonTemplate = file!.readAsStringSync();
        }
      }
    } else {
      //Uri baseUrl = IConfigService().baseUrl.value!;
      //String appName = IConfigService().appName.value!;

      //imageProvider = NetworkImage("$baseUrl/resource/$appName/$imageDefinition_", headers: _getHeaders());
    }

    if (jsonTemplate != null) {
      final registry = JsonWidgetRegistry.instance;

      registry.registerCustomBuilder("list_image", const JsonWidgetBuilderContainer(builder: ListImageBuilder.fromDynamic));
      registry.clearValues();

      for (int i = 0; i < model.columnNames.length; i++) {
        int columnIndex = columnDefinitions.indexByName(model.columnNames[i]);

        if (columnIndex >= 0) {
          registry.setValue(model.columnNames[i], values[columnIndex]);
        }
      }

      return JsonWidgetData.fromDynamic(
        jsonDecode(jsonTemplate),
        registry: registry,
      ).build(context: context);
    }

    return null;
  }

  Widget _defaultEntry(BuildContext context) {
    String? imageColumn;
    List<String> valueColumns = [];
    List<String> checkBoxColumns = [];

    //search image column and collect all "text" columns
    for (int i = 0; i < model.columnNames.length; i++) {
      int columnIndex = columnDefinitions.indexByName(model.columnNames[i]);

      if (columnIndex >= 0) {
        ColumnDefinition colDef = columnDefinitions[columnIndex];

        if (colDef.dataTypeIdentifier == Types.BINARY) {
          //fifo
          imageColumn ??= model.columnNames[i];
        }
        else if (FlCellEditorClassname.CHOICE_CELL_EDITOR != colDef.cellEditorClassName &&
                 FlCellEditorClassname.CHECK_BOX_CELL_EDITOR != colDef.cellEditorClassName) {
          valueColumns.add(model.columnNames[i]);
        }
        else if (FlCellEditorClassname.CHECK_BOX_CELL_EDITOR == colDef.cellEditorClassName ||
                 FlCellEditorClassname.CHOICE_CELL_EDITOR == colDef.cellEditorClassName) {
          checkBoxColumns.add(model.columnNames[i]);
        }
      }
    }

    int maxColumns = valueColumns.length;
    int colPos = 0;
    int cols;

    List<Widget> liRows = [];

    Widget? row;

    Widget? valueAsText;

    CellFormat? cellFormat;

    String colName;
    int colIndex;
    int sepIndex = 0;

    //we show per default max. 3 Rows, but it's possible to show more than 1 column per row
    //also if more rows are defined per columns, it's possible to have more than 3 rows
    for (int i = 0; i < math.max(3, columnsPerRow?.length ?? 0) && colPos < maxColumns; i++) {
      row = null;

      if (columnsPerRow?[i] != null) {
        //if we have columns per row, "join" text in one row
        cols = columnsPerRow![i]!;

        if (cols == 0) {
          //0 per definition is special (means: empty row)
          row = const Row(children: [Text("")]);
        }
        else {
          List<Widget> liColumns = [];

          for (int j = 0; j < cols && colPos < maxColumns; j++) {
            colName = valueColumns[colPos++];
            colIndex = columnDefinitions.indexByName(colName);
            cellFormat = recordFormat?.getCellFormat(index, colIndex);

            valueAsText = _createTextWidget(cellEditors[colName], values[colIndex], cellFormat);
            valueAsText = _applyCellProfileImageOrIndent(valueAsText, cellFormat);

            String? separator;

            if (j > 0) {
              if (columnSeparator != null && sepIndex < columnSeparator!.length) {
                separator = columnSeparator![sepIndex++];
              }
              else {
                separator = " ";
              }
            }

            if (valueAsText != null) {
              if (liColumns.isNotEmpty) {
                liColumns.add(Text(separator ?? " "));
              }

              liColumns.add(valueAsText);
            }
          }

          if (liColumns.isNotEmpty) {
            if (liColumns.length == 1) {
              //no wrapping needed to avoid overflow
              row = Row(children: [Flexible(child: liColumns[0])]);
            }
            else {
              //wrap to avoid overflow
              row = Wrap(children: liColumns);
            }
          }
        }
      }
      else {
        colName = valueColumns[colPos++];
        colIndex = columnDefinitions.indexByName(colName);
        cellFormat = recordFormat?.getCellFormat(index, colIndex);

        valueAsText = _createTextWidget(cellEditors[colName], values[colIndex], cellFormat);
        valueAsText = _applyCellProfileImageOrIndent(valueAsText, cellFormat);

        if (valueAsText != null) {
          //avoid overflow
          row = Row(children: [Flexible(child: valueAsText)]);
        }
      }

      //if we don't have an image column -> show empty rows, otherwise list entries will have different height
      if (row == null && imageColumn == null) {
        row = const Row(children: [Text("")]);
      }

      if (row != null) {
        liRows.add(row);

        //add gap to text rows
        if (liRows.length > 1) {
          //Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0)
          liRows[liRows.length - 1] = Padding(padding: const EdgeInsets.only(top: 5), child: liRows[liRows.length - 1]);
        }
      }
    }

    List<Widget> checks = [];

    dynamic value;

    String? separator;

    for (int i = 0; i < checkBoxColumns.length; i++) {
      cellEditors[checkBoxColumns[i]]!.setValue(values[columnDefinitions.indexByName(checkBoxColumns[i])]);

      Widget w = cellEditors[checkBoxColumns[i]]!.createWidget(model.json);

      if (i > 0) {
        if (columnSeparator != null && sepIndex < columnSeparator!.length) {
          separator = columnSeparator![sepIndex++];
        }
        else {
          separator = " ";
        }
      }

      if (checks.isNotEmpty) {
        checks.add(Text(separator ?? " "));
      }
      
      //no changes possible
      checks.add(AbsorbPointer(
        absorbing: true,
        child: w),
      );
    }

    if (checks.isNotEmpty) {
      liRows.add(Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: checks)
      ));
    }

    //No rows, show an info text
    if (liRows.isEmpty) {
      return Container(height: 30, color: Colors.red.shade300, child: const Text("No columns"));
    }

    Widget? widget;

    if (imageColumn != null) {
      CellFormat? format = recordFormat?.getCellFormat(index, columnDefinitions.indexByName(imageColumn));

      widget = IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: format?.background ?? Colors.grey.shade200,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: ListImage(
                  imageDefinition: values[columnDefinitions.indexByName(imageColumn)],
                  iconColor: format?.foreground,
                )
              )
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 5, top: 5, bottom: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: mainAxisAlignment,
                  children: liRows
                )
              )
            )
          ]
        )
      );
    }
    else {
      widget = Padding(
        padding: const EdgeInsets.only(left: 5, top: 5, bottom: 5),
        child: Column(
          mainAxisAlignment: mainAxisAlignment,
          children: liRows
        )
      );
    }

    return widget;
  }

  /// Creates a normal text widget for the cell.
  Text? _createTextWidget(ICellEditor? cellEditor, dynamic value, CellFormat? format) {

    //similar code available in [FlTableCell]
    if (cellEditor != null) {

      String cellText = cellEditor.formatValue(value);
      TextStyle style = model.createTextStyle();

      style = style.copyWith(
        backgroundColor: format?.background,
        color: format?.foreground,
        fontWeight: format?.font?.isBold == true ? FontWeight.bold : null,
        fontStyle: format?.font?.isItalic == true ? FontStyle.italic : null,
        fontFamily: format?.font?.fontName,
        fontSize: format?.font?.fontSize.toDouble(),
      );

      TextAlign textAlign;
      if (cellEditor.model.horizontalAlignment == HorizontalAlignment.RIGHT) {
        textAlign = TextAlign.right;
      } else {
        textAlign = TextAlign.left;
      }

      if (cellEditor.model.className == FlCellEditorClassname.TEXT_CELL_EDITOR &&
          cellEditor.model.contentType == FlTextCellEditor.TEXT_PLAIN_PASSWORD) {
        cellText = "•" * cellText.length;
      }

      if (cellText.isNotEmpty) {
        return Text(
          cellText,
          style: style,
          overflow: TextOverflow.ellipsis,
          maxLines: model.wordWrapEnabled ? null : 1,
          textAlign: textAlign,
        );
      }
      else {
        return null;
      }
    }
    else {
      return null;
    }
  }

  /// Applies cell format image or indent to given text widget
  Widget? _applyCellProfileImageOrIndent(Widget? text, CellFormat? cellFormat) {
    //similar code available in [FlTableCell]
    List<Widget> widgets;

    double indent = cellFormat?.leftIndent?.toDouble() ?? 0;

    if (cellFormat?.imageString == null
        || cellFormat?.imageString?.isEmpty == true) {

      if (indent > 0) {
        widgets = [Padding(padding: EdgeInsets.only(left: indent))];
      }
      else {
        widgets = [];
      }
    }
    else {
      Widget? cellImage = ImageLoader.loadImage(
        cellFormat!.imageString!,
        color: cellFormat.foreground,
      );

      if (text != null) {
        widgets = [Padding(padding: EdgeInsets.only(right: FlTableCell.formatImageGap, left: indent), child: cellImage)];
      }
      else {
        widgets = [cellImage];
      }
    }

    //No indent or image -> use text as it is
    if (widgets.isEmpty) {
      return text;
    }

    //for the height!
    widgets.add(text ?? const Text(""));

    //row would use the fill width without IntrinsicWidth
    return IntrinsicWidth(child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widgets,
    ));
  }
}
