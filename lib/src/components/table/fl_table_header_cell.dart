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

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../flutter_jvx.dart';
import '../../model/data/sort_definition.dart';
import '../../model/layout/alignments.dart';
import '../editor/cell_editor/fl_dummy_cell_editor.dart';

class FlTableHeaderCell extends FlStatelessWidget<FlTableModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // Callbacks

  /// Gets called with the name of column when the user taps a cell.
  final TableHeaderTapCallback? onTap;

  /// Gets called with the name of column when the user taps a cell.
  final TableHeaderTapCallback? onDoubleTap;

  /// Gets called with the name of column when the user long presses a cell.
  final TableLongPressCallback? onLongPress;

  // Fields

  /// The [ColumnDefinition] of this table cell.
  final ColumnDefinition columnDefinition;

  /// The width of the cell.
  final double width;

  /// The cell paddings
  final EdgeInsets paddings;

  /// The index of the row this column is in.
  final int rowIndex = -1;

  /// The index of the cell in the row;
  final int cellIndex;

  /// If the cell is not first, has border on the left side.
  final double cellDividerWidth;

  /// A dummy cell editor for callbacks.
  final FlDummyCellEditor dummyCellEditor = FlDummyCellEditor();

  /// Sort Mode
  final SortMode? sortMode;

  /// The index of the sort.
  final int? sortIndex;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlTableHeaderCell({
    required super.model,
    this.onLongPress,
    this.onTap,
    this.onDoubleTap,
    required this.columnDefinition,
    required this.width,
    required this.paddings,
    required this.cellIndex,
    required this.cellDividerWidth,
    this.sortMode,
    this.sortIndex,
  }) : super(key: UniqueKey());

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    Widget? cellChild;

    cellChild ??= _createTextWidget();

    Border? border = const Border(
      bottom: BorderSide(
        color: JVxColors.COMPONENT_BORDER,
      ),
    );

    // The first cell does not get a left border
    if (model.showVerticalLines && cellIndex != 0) {
      Border verticalBorder = Border(
          left: BorderSide(
        color: JVxColors.TABLE_VERTICAL_DIVIDER,
        width: cellDividerWidth,
      ));

      border = Border.merge(verticalBorder, border);
    }

    return GestureDetector(
      onLongPressStart: onLongPress != null && model.isEnabled
          ? (details) => onLongPress!(rowIndex, columnDefinition.name, dummyCellEditor, details.globalPosition)
          : null,
      onTap: onTap != null && model.isEnabled ? () => onTap!(columnDefinition.name) : null,
      onDoubleTap: onDoubleTap != null && model.isEnabled ? () => onDoubleTap!(columnDefinition.name) : null,
      child: Container(
        decoration: BoxDecoration(
          border: border,
        ),
        width: max(width, 0.0),
        alignment: FLUTTER_ALIGNMENT[columnDefinition.cellEditorHorizontalAlignment.index]
            [VerticalAlignment.CENTER.index],
        padding: paddings,
        child: cellChild,
      ),
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Creates a normal text widget for the cell.
  Widget _createTextWidget() {
    String cellText;
    TextStyle style;

    cellText = columnDefinition.label;

    if (columnDefinition.nullable != true) {
      ApplicationMetaDataResponse? metadata = IUiService().applicationMetaData.value;

      if (metadata != null) {
        if (metadata.mandatoryMarkVisible) {
          cellText += " ${metadata.mandatoryMark ?? "*"}";
        }
      }
      else {
        cellText += " *";
      }
    }

    style = model.createTextStyle(pFontWeight: FontWeight.bold);

    Text text =
        Text(cellText, style: style, overflow: TextOverflow.ellipsis, maxLines: model.wordWrapEnabled ? null : 1);

    if (sortMode == null) {
      return text;
    }

    MainAxisAlignment mainAxisAlignment;
    if (columnDefinition.cellEditorHorizontalAlignment == HorizontalAlignment.RIGHT) {
      mainAxisAlignment = MainAxisAlignment.end;
    } else {
      mainAxisAlignment = MainAxisAlignment.start;
    }

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      children: [
        text,
        const SizedBox(
          width: 5,
        ),
        FaIcon(
          sortMode == SortMode.ascending ? FontAwesomeIcons.sortUp : FontAwesomeIcons.sortDown,
          size: 16,
        ),
        if (sortIndex != null)
          Text(
            sortIndex!.toString(),
            style: style.copyWith(fontSize: 8),
            maxLines: 1,
          ),
      ],
    );
  }
}
