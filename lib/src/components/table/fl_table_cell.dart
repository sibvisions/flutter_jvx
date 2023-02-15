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
import '../../model/component/fl_component_model.dart';
import '../../model/layout/alignments.dart';
import '../../model/response/dal_fetch_response.dart';
import '../base_wrapper/fl_stateful_widget.dart';
import '../editor/cell_editor/fl_dummy_cell_editor.dart';
import '../editor/cell_editor/i_cell_editor.dart';

class FlTableCell extends FlStatefulWidget<FlTableModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // Callbacks

  /// The callback if a value has ended beeing changed in the table.
  final TableValueChangedCallback? onEndEditing;

  /// The callback if a value has been changed in the table.
  final TableValueChangedCallback? onValueChanged;

  /// Gets called with the index of the row and name of column when the user taps a cell.
  /// Provides the celleditor of this cell, allowing to click the cell editor.
  /// Allows validation of the click before allowing the cell editor to be clicked.
  final TableTapCallback? onTap;

  /// Gets called with the index of the row and name of column when the user taps a cell.
  /// Provides the celleditor of this cell, allowing to click the cell editor.
  /// Allows validation of the click before allowing the cell editor to be clicked.
  final TableTapCallback? onDoubleTap;

  /// Gets called with the index of the row and name of column when the user long presses a cell.
  final TableLongPressCallback? onLongPress;

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

  /// The index of the cell in the row;
  final int cellIndex;

  /// If the cell is not first, has border on the left side.
  final double cellDividerWidth;

  /// The format of the cell.
  final CellFormat? cellFormat;

  /// If this column is selected.
  final bool isSelected;
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlTableCell({
    required super.model,
    this.onEndEditing,
    this.onValueChanged,
    this.onLongPress,
    this.onTap,
    this.onDoubleTap,
    required this.columnDefinition,
    required this.width,
    required this.paddings,
    this.value,
    this.rowIndex = -1,
    required this.cellIndex,
    required this.cellDividerWidth,
    this.cellFormat,
    this.isSelected = false,
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

    if (widget.cellFormat?.imageString.isNotEmpty == true) {
      cellChild = ImageLoader.loadImage(
        widget.cellFormat!.imageString,
        pWantedColor: widget.cellFormat?.foreground,
      );
    }

    cellChild ??= _createCellEditorWidget();

    cellChild ??= _createTextWidget();

    Border? border;
    if (widget.model.showHorizontalLines) {
      border = Border(
        bottom: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 0.3,
        ),
      );
    }

    // The first cell does not get a left border
    if (widget.model.showVerticalLines && widget.cellIndex != 0) {
      Border verticalBorder = Border(
          left: BorderSide(
        color: JVxColors.TABLE_VERTICAL_DIVICER,
        width: widget.cellDividerWidth,
      ));

      if (border == null) {
        border = verticalBorder;
      } else {
        border = Border.merge(verticalBorder, border);
      }
    }

    EdgeInsets paddings = widget.paddings;
    if (widget.model.showFocusRect && widget.isSelected) {
      border = Border.all(
        color: JVxColors.TABLE_FOCUS_REACT,
        width: 1,
      );
      paddings = paddings - const EdgeInsets.all(1);
    }

    return GestureDetector(
      onLongPressStart: widget.onLongPress != null && widget.model.isEnabled
          ? (details) => widget.onLongPress!(widget.rowIndex, widget.columnDefinition.name, cellEditor, details)
          : null,
      onTap: widget.onTap != null && widget.model.isEnabled
          ? () => widget.onTap!(widget.rowIndex, widget.columnDefinition.name, cellEditor)
          : null,
      onDoubleTap: widget.onDoubleTap != null && widget.model.isEnabled
          ? () => widget.onDoubleTap!(widget.rowIndex, widget.columnDefinition.name, cellEditor)
          : null,
      child: Container(
        decoration: BoxDecoration(
          border: border,
          color: widget.cellFormat?.background,
        ),
        width: widget.width,
        alignment: FLUTTER_ALIGNMENT[widget.columnDefinition.cellEditorHorizontalAlignment.index]
            [VerticalAlignment.CENTER.index],
        padding: paddings,
        child: Row(
          children: [
            Expanded(
              child: cellChild,
            ),
            ..._createCellIcons(),
          ],
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
    cellEditor.dispose();

    cellEditor = ICellEditor.getCellEditor(
      pName: widget.model.name,
      columnDefinition: widget.columnDefinition,
      pCellEditorJson: widget.columnDefinition.cellEditorJson,
      onChange: widget.model.isEnabled && widget.model.editable
          ? (value) => widget.onValueChanged?.call(value, widget.rowIndex, widget.columnDefinition.name)
          : _doNothing,
      onEndEditing: widget.model.isEnabled && widget.model.editable
          ? (value) => widget.onEndEditing?.call(value, widget.rowIndex, widget.columnDefinition.name)
          : _doNothing,
      onFocusChanged: (_) {},
      isInTable: true,
    );

    cellEditor.cellFormat = widget.cellFormat;
    cellEditor.setValue(widget.value);
  }

  void _doNothing(dynamic pNothing) {}

  /// Creates the cell editor widget for the cell if possible
  Widget? _createCellEditorWidget() {
    if (!cellEditor.allowedInTable) {
      return null;
    }

    FlStatelessWidget tableWidget = cellEditor.createWidget(widget.model.json);

    return AbsorbPointer(
      absorbing: !widget.model.isEnabled || !widget.model.editable,
      child: tableWidget,
    );
  }

  /// Creates a normale textwidget for the cell.
  Widget _createTextWidget() {
    String cellText = cellEditor.formatValue(widget.value);
    TextStyle style = widget.model.createTextStyle();

    style = style.copyWith(
      backgroundColor: widget.cellFormat?.background,
      color: widget.cellFormat?.foreground,
      fontWeight: widget.cellFormat?.font?.isBold == true ? FontWeight.bold : null,
      fontStyle: widget.cellFormat?.font?.isItalic == true ? FontStyle.italic : null,
      fontFamily: widget.cellFormat?.font?.fontName,
      fontSize: widget.cellFormat?.font?.fontSize.toDouble(),
    );

    TextAlign textAlign;
    if (cellEditor.model.horizontalAlignment == HorizontalAlignment.RIGHT) {
      textAlign = TextAlign.right;
    } else {
      textAlign = TextAlign.left;
    }

    return Text(
      cellText,
      style: style,
      overflow: TextOverflow.ellipsis,
      maxLines: widget.model.wordWrapEnabled ? null : 1,
      textAlign: textAlign,
    );
  }

  List<Widget> _createCellIcons() {
    List<Widget> icons = [];

    bool isLight = Theme.of(FlutterUI.getCurrentContext()!).brightness == Brightness.light;
    if (cellEditor.tableDeleteIcon && cellEditor.allowedTableEdit && !_isValueNullOrEmpty()) {
      icons.add(
        Center(
          child: InkWell(
            canRequestFocus: false,
            onTap: () {
              widget.onEndEditing?.call(null, widget.rowIndex, widget.columnDefinition.name);
            },
            child: SizedBox(
              width: 24,
              height: 24,
              child: Icon(
                Icons.clear,
                size: 16,
                color: isLight ? JVxColors.COMPONENT_DISABLED : JVxColors.COMPONENT_DISABLED_LIGHTER,
              ),
            ),
          ),
        ),
      );
    }

    if (cellEditor.tableEditIcon != null) {
      icons.add(
        Center(
          child: Icon(
            cellEditor.tableEditIcon,
            size: 16,
            color: isLight ? JVxColors.COMPONENT_DISABLED : JVxColors.COMPONENT_DISABLED_LIGHTER,
          ),
        ),
      );
    }

    return icons;
  }

  bool _isValueNullOrEmpty() {
    if (widget.value is Map<String, dynamic> || widget.value is List<dynamic>) {
      return widget.value == null || widget.value.length == 0;
    }
    return widget.value == null || "" == widget.value;
  }
}
