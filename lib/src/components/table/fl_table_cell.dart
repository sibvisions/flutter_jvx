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

import '../../../flutter_jvx.dart';
import '../../model/layout/alignments.dart';
import '../base_wrapper/fl_stateful_widget.dart';
import '../editor/cell_editor/fl_dummy_cell_editor.dart';
import '../editor/cell_editor/i_cell_editor.dart';

class FlTableCell extends FlStatefulWidget<FlTableModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // Callbacks

  /// The callback if a value has ended beeing changed in the table.
  final Function(dynamic value, int row, String column)? onEndEditing;

  /// The callback if a value has been changed in the table.
  final Function(dynamic value, int row, String column)? onValueChanged;

  /// Gets called with the index of the row and name of column when the user taps a cell.
  /// Provides the celleditor of this cell, allowing to click the cell editor.
  /// Allows validation of the click before allowing the cell editor to be clicked.
  final Function(int rowIndex, String column, ICellEditor cellEditor)? onTap;

  /// Gets called with the index of the row and name of column when the user long presses a cell.
  final Function(int rowIndex, String column, LongPressStartDetails details)? onLongPress;

  // Fields

  /// The [ColumnDefinition] of this table cell.
  final ColumnDefinition columnDefinition;

  /// The width of the cell.
  final double width;

  /// The cell paddings
  final EdgeInsets paddings;

  /// The value of the cell;
  final dynamic value;

  /// The index of the row this column is in.
  final int rowIndex;

  /// If the cell is forced to only display a text widget
  final bool disableEditor;

  /// The index of the cell in the row;
  final int cellIndex;

  /// If the cell is not first, has border on the left side.
  final double cellDividerWidth;

  /// If the cell is in the header row.
  final bool isHeader;
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlTableCell({
    required super.model,
    this.onEndEditing,
    this.onValueChanged,
    this.onLongPress,
    this.onTap,
    required this.columnDefinition,
    required this.width,
    required this.paddings,
    this.value,
    this.rowIndex = -1,
    required this.cellIndex,
    required this.cellDividerWidth,
    this.disableEditor = false,
    this.isHeader = false,
  }) : super(key: UniqueKey());

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  State<FlTableCell> createState() => _FlTableCellState();
}

class _FlTableCellState extends State<FlTableCell> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The celleditor of the cell.
  ICellEditor cellEditor = FlDummyCellEditor();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    _rebuildCellEditor();

    Widget? cellChild;

    if (!widget.disableEditor) {
      cellChild = _createCellEditorWidget();
    }

    cellChild ??= _createTextWidget();

    Border? border;
    if (widget.isHeader) {
      border = const Border(
        bottom: BorderSide(
          color: JVxColors.COMPONENT_BORDER,
        ),
      );
    } else if (widget.model.showHorizontalLines) {
      border = Border(
        bottom: BorderSide(
          color: Theme.of(context).primaryColor,
          width: 0.3,
        ),
      );
    }

    // The first cell does not get a left border
    if (widget.model.showVerticalLines && widget.cellIndex != 0) {
      Border verticalBorder = Border(
          left: BorderSide(
        color: JVxColors.COMPONENT_BORDER,
        width: widget.cellDividerWidth,
      ));

      if (border == null) {
        border = verticalBorder;
      } else {
        border = Border.merge(verticalBorder, border);
      }
    }

    return GestureDetector(
      onLongPressStart: widget.onLongPress != null
          ? (details) => widget.onLongPress!(widget.rowIndex, widget.columnDefinition.name, details)
          : null,
      onTap:
          widget.onTap != null ? () => widget.onTap!(widget.rowIndex, widget.columnDefinition.name, cellEditor) : null,
      child: AbsorbPointer(
        child: Container(
          decoration: BoxDecoration(border: border),
          width: widget.width,
          alignment: FLUTTER_ALIGNMENT[widget.columnDefinition.cellEditorHorizontalAlignment.index]
              [VerticalAlignment.CENTER.index],
          padding: widget.paddings,
          child: cellChild,
        ),
      ),
    );
  }

  @override
  void dispose() {
    cellEditor.dispose();
    super.dispose();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Builds the cell editor.
  void _rebuildCellEditor() {
    if (widget.isHeader) {
      return;
    }

    cellEditor.dispose();
    cellEditor = ICellEditor.getCellEditor(
      pName: widget.model.name,
      columnDefinition: widget.columnDefinition,
      pCellEditorJson: widget.columnDefinition.cellEditorJson,
      onChange: (value) => widget.onValueChanged?.call(value, widget.rowIndex, widget.columnDefinition.name),
      onEndEditing: (value) => widget.onEndEditing?.call(value, widget.rowIndex, widget.columnDefinition.name),
      onFocusChanged: (_) {},
    );
  }

  /// Creates the cell editor widget for the cell if possible
  Widget? _createCellEditorWidget() {
    if (widget.isHeader || !cellEditor.allowedInTable) {
      return null;
    }

    cellEditor.setValue(widget.value);

    FlStatelessWidget tableWidget = cellEditor.createWidget(null, true);

    tableWidget.model.applyFromJson(widget.model.json);
    // Some parts of a json have to take priority.
    // As they override the properties.
    tableWidget.model.applyCellEditorOverrides(widget.model.json);

    return tableWidget;
  }

  /// Creates a normale textwidget for the cell.
  Widget _createTextWidget() {
    String cellText;
    TextStyle style;
    if (widget.isHeader) {
      cellText = widget.columnDefinition.label;

      if (widget.columnDefinition.nullable != true) {
        cellText += " *";
      }

      style = widget.model.createTextStyle(pFontWeight: FontWeight.bold);
    } else {
      cellText = cellEditor.formatValue(widget.value);
      style = widget.model.createTextStyle();
    }

    return Text(
      cellText,
      style: style,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }
}
