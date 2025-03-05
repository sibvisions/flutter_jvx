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

import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:json_dynamic_widget/json_dynamic_widget.dart';

import '../../../flutter_jvx.dart';
import '../../model/layout/alignments.dart';
import '../../model/response/record_format.dart';
import '../../service/api/shared/fl_component_classname.dart';
import '../../util/column_list.dart';
import '../../util/extensions/color_extensions.dart';
import '../../util/i_types.dart';
import '../editor/cell_editor/i_cell_editor.dart';
import '../table/fl_table_cell.dart';
import 'builder/list_cell_builder.dart';
import 'builder/list_image_builder.dart';

typedef DismissedCallback = void Function(int index);

typedef ListEntryBuilder = Widget? Function(
  BuildContext context,
  FlListEntry widget
);

class FlListEntry extends FlStatelessWidget<FlTableModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// the widget registry
  final JsonWidgetRegistry registry;

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
  final dynamic jsonTemplate;

  /// the column separators
  final List<String>? columnSeparator;

  /// column count per row, from [columnDefinitions]
  final Map<int, int>? columnsPerRow;

  /// the cell editors
  final Map<String, ICellEditor> cellEditors;

  /// the entry builder
  final ListEntryBuilder? _entryBuilder;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlListEntry({super.key,
    required super.model,
    required this.registry,
    required this.columnDefinitions,
    required this.cellEditors,
    required this.values,
    required this.index,
    required this.isSelected,
    this.recordFormat,
    this.jsonTemplate,
    this.columnsPerRow,
    this.columnSeparator,
    mainAxisAlignment,
    ListEntryBuilder? entryBuilder}) : mainAxisAlignment = mainAxisAlignment ?? MainAxisAlignment.center, _entryBuilder = entryBuilder;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    if (_entryBuilder != null) {
      Widget? w = _entryBuilder!(context, this);

      if (w != null) {
        return w;
      }
    }
    else {
      if (jsonTemplate != null) {
        return _fromTemplate(context, jsonTemplate!);
      }
    }

    return _defaultEntry(context);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Creates a list entry from given json template
  Widget _fromTemplate(BuildContext context, dynamic jsonTemplate)  {
    //gets the raw value for a specific column
    registry.registerFunction("getValue", ({args, required registry}) {
      if (args != null) {
        return values[columnDefinitions.indexByName(args[0])];
      }

      return null;
    });

    /// gets the cell format for a specific column
    registry.registerFunction("getCellFormat", ({args, required registry}) {
      if (args != null) {
        return recordFormat?.getCellFormat(index, columnDefinitions.indexByName(args[0]));
      }

      return null;
    });

    /// gets the background of cell format for a specific column
    registry.registerFunction("background", ({args, required registry}) {

      if (args != null) {
        CellFormat? cf = recordFormat?.getCellFormat(index, columnDefinitions.indexByName(args[0]));

        return cf?.background?.toHex() ?? (args.length > 1 ? args[1] : null);
      }

      return null;
    });

    /// gets the foreground of cell format for a specific column
    registry.registerFunction("foreground", ({args, required registry}) {

      if (args != null) {
        CellFormat? cf = recordFormat?.getCellFormat(index, columnDefinitions.indexByName(args[0]));

        return cf?.foreground?.toHex() ?? (args.length > 1 ? args[1] : null);
      }

      return null;
    });

    //format a list_cell value (similar to _defaultEntry)
    registry.registerFunction("formatListCell", ({args, required registry}) {
      if (args != null) {
        ListCell cell = args.elementAt(0);

        if (cell.columnName != null) {
          int columnIndex = columnDefinitions.indexByName(cell.columnName!);

          Widget? w;

          if (columnIndex > 0) {
            ColumnDefinition colDef = columnDefinitions.byName(cell.columnName!)!;

            if (FlCellEditorClassname.CHECK_BOX_CELL_EDITOR == colDef.cellEditorClassName ||
                FlCellEditorClassname.CHOICE_CELL_EDITOR == colDef.cellEditorClassName) {

               w = IntrinsicWidth(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: _getCheckBoxWidget(cell.columnName!, cell.prefix, cell.postfix))
              );
            }
          }

          if (w == null) {
            w = _createTextWidget(
                cellEditors[cell.columnName],
                values[columnIndex],
                recordFormat?.getCellFormat(index, columnIndex));

            if (cell.useFormat) {
              w = _applyCellProfileImageOrIndent(w, recordFormat?.getCellFormat(index, columnIndex), cell.prefix, cell.postfix);
            }
            else if (w != null) {
              if (cell.postfix != null || cell.prefix != null) {
                List<Widget> widgets = [];

                if (cell.prefix != null) {
                  widgets.add(Text(cell.prefix!));
                }

                widgets.add(w);

                if (cell.postfix != null) {
                  widgets.add(Text(cell.postfix!));
                }

                return IntrinsicWidth(child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: widgets,
                ));
              }
            }
          }

          return w;
        }
      }

      return const Text("");
    });

    //check if ALL given column names have a value != null and not empty
    registry.registerFunction("hasValue", ({args, required registry}) {
      if (args != null) {
        dynamic columnNames = args;

        List<dynamic>? columns;

        if (columnNames is List<dynamic>) {
          columns = columnNames;
        }
        else if (columnNames is String) {
          columns = [columnNames];
        }

        bool hasValues;

        if (columns != null) {
          hasValues = true;

          for (int i = 0; i < columns.length; i++) {
            int columnIndex = columnDefinitions.indexByName(columns[i]);

            hasValues &= values[columnIndex] != null && values[columnIndex].toString().isNotEmpty;
          }
        }
        else {
          hasValues = false;
        }

        return hasValues;
      }

      return const Text("");
    });

    registry.clearValues();

    int colIndex;

    for (int i = 0; i < model.columnNames.length; i++) {
      colIndex = columnDefinitions.indexByName(model.columnNames[i]);

      if (colIndex >= 0) {
        registry.setValue(model.columnNames[i], values[colIndex]);
      }
    }

    Widget w = JsonWidgetData.fromDynamic(
      jsonTemplate,
      registry: registry,
    ).build(context: context);

    return w;
  }

  /// Creates a default entry if no template is available
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
            valueAsText = _applyCellProfileImageOrIndent(valueAsText, cellFormat, null, null);

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
        valueAsText = _applyCellProfileImageOrIndent(valueAsText, cellFormat, null, null);

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

    List<Widget> liCheckBoxes = [];

    String? separator;

    for (int i = 0; i < checkBoxColumns.length; i++) {
      if (i > 0) {
        if (columnSeparator != null && sepIndex < columnSeparator!.length) {
          separator = columnSeparator![sepIndex++];
        }
        else {
          separator = " ";
        }
      }

      if (liCheckBoxes.isNotEmpty) {
        liCheckBoxes.add(Text(separator ?? " "));
      }

      liCheckBoxes.addAll(_getCheckBoxWidget(checkBoxColumns[i]));
    }

    if (liCheckBoxes.isNotEmpty) {
      liRows.add(Padding(
        padding: const EdgeInsets.only(top: 15),
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: liCheckBoxes)
      ));
    }

    //No rows, show an info text
    if (liRows.isEmpty) {
      return Container(height: 30, color: Colors.red.shade300, child: Text(FlutterUI.translate("No columns")));
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
                child: ListImage.predefined(
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
  Widget? _applyCellProfileImageOrIndent(Widget? text, CellFormat? cellFormat, String? prefix, String? postfix) {
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
    if (widgets.isEmpty && postfix == null && prefix == null) {
      return text;
    }

    if (text != null && prefix != null) {
      widgets.insert(0, Text(prefix));
    }

    //for the height!
    widgets.add(text ?? const Text(""));

    if (text != null && postfix != null) {
      widgets.add(Text(postfix));
    }

    //row would use the fill width without IntrinsicWidth
    return IntrinsicWidth(child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widgets,
    ));
  }

  /// Gets a checkbox widget (choice or checkbox - with different styles). The widget may contain
  /// a label
  List<Widget> _getCheckBoxWidget(String columnName, [String? prefix, String? postfix]) {
    ICellEditor ced = cellEditors[columnName]!;

    ced.setValue(values[columnDefinitions.indexByName(columnName)]);

    List<Widget> widgets = [];

    Widget w = ced.createWidget(model.json);

    //no changes possible
    w = AbsorbPointer(
        absorbing: true,
        child: w);

    if (prefix != null) {
      widgets.add(Text(prefix));
    }

    widgets.add(w);

    //check if label is necessary
    ColumnDefinition? colDef = columnDefinitions.byName(columnName);

    if (colDef?.label.isNotEmpty == true) {

      if (ced is FlCheckBoxCellEditor) {
        if (ced.model.styles.none((style) =>
        style == FlCheckBoxModel.STYLE_SWITCH ||
            style == FlCheckBoxModel.STYLE_UI_SWITCH ||
            style == FlCheckBoxModel.STYLE_UI_BUTTON ||
            style == FlCheckBoxModel.STYLE_UI_TOGGLEBUTTON ||
            style == FlCheckBoxModel.STYLE_UI_HYPERLINK)) {
          widgets.add(Text(" ${colDef!.label}"));
        }
      }
    }

    if (postfix != null) {
      widgets.add(Text(postfix));
    }

    return widgets;
  }

}
