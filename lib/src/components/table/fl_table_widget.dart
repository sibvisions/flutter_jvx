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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../model/component/table/fl_table_model.dart';
import '../../model/data/subscriptions/data_chunk.dart';
import '../base_wrapper/fl_stateless_widget.dart';
import '../editor/cell_editor/fl_dummy_cell_editor.dart';
import '../editor/cell_editor/i_cell_editor.dart';
import 'fl_table_header_row.dart';
import 'fl_table_row.dart';
import 'table_size.dart';

typedef TableLongPressCallback = void Function(
    int rowIndex, String column, ICellEditor cellEditor, LongPressStartDetails details);
typedef TableTapCallback = void Function(int rowIndex, String column, ICellEditor cellEditor);
typedef TableValueChangedCallback = void Function(dynamic value, int row, String column);
typedef CellEditorActionCallback = void Function(int rowIndex, String column, Function action);

class FlTableWidget extends FlStatelessWidget<FlTableModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // Controllers

  /// The scroll controller of the table.
  final ItemScrollController? itemScrollController;

  /// The scroll controller for the table.
  final ScrollController? tableHorizontalController;

  /// The scroll controller for the headers if they are set to sticky.
  final ScrollController? headerHorizontalController;

  // Callbacks

  /// The callback if a value has ended beeing changed in the table.
  final TableValueChangedCallback? onEndEditing;

  /// The callback if a value has been changed in the table.
  final TableValueChangedCallback? onValueChanged;

  /// Gets called with the index of the row that was touched when the user tapped a row.
  final TableTapCallback? onTap;

  /// Gets called with the index of the row that was touched when the user tapped a row.
  final TableTapCallback? onDoubleTap;

  /// Gets called when the user long presses the table or a row/column.
  final TableLongPressCallback? onLongPress;

  /// Gets called when the user scrolled to the edge of the table.
  final VoidCallback? onEndScroll;

  /// Gets called when an action cell editor makes an action.
  final CellEditorActionCallback? onAction;

  // Fields

  /// Contains all relevant table size information.
  final TableSize tableSize;

  /// The selected current row.
  final int selectedRowIndex;

  /// The data of the table.
  final DataChunk chunkData;

  /// Whether or not to disable all editors.
  final bool disableEditors;

  /// If a button is shown at the bottom.
  final bool showFloatingButton;

  /// The action the floating button calls.
  final VoidCallback? floatingOnPress;

  /// How many items the scrollable list should build.
  int get _itemCount {
    int itemCount = chunkData.data.length;

    if (model.tableHeaderVisible && !model.stickyHeaders) {
      itemCount += 1;
    }

    return itemCount;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlTableWidget({
    super.key,
    required super.model,
    required this.chunkData,
    required this.tableSize,
    this.tableHorizontalController,
    this.headerHorizontalController,
    this.selectedRowIndex = -1,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onAction,
    this.onEndScroll,
    this.itemScrollController,
    this.onEndEditing,
    this.onValueChanged,
    this.disableEditors = false,
    this.showFloatingButton = false,
    this.floatingOnPress,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    BorderRadius borderRadius = BorderRadius.circular(5.0);

    List<Widget> children = [LayoutBuilder(builder: createTableBuilder)];

    if (showFloatingButton && floatingOnPress != null) {
      children.add(createFloatinButton());
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(width: tableSize.borderWidth, color: Theme.of(context).primaryColor),
        color: Theme.of(context).backgroundColor,
      ),
      child: ClipRRect(
        // The clip rect is there to stop the rendering of the children.
        // Otherwise the children would clip the border of the parent container.
        borderRadius: borderRadius,
        child: Stack(
          children: children,
        ),
      ),
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Creates the floating button that floats above the table on the bottom right
  Positioned createFloatinButton() {
    return Positioned(
      right: 10,
      bottom: 10,
      child: FloatingActionButton(
        onPressed: floatingOnPress,
        child: FaIcon(
          FontAwesomeIcons.squarePlus,
          color: model.foreground,
        ),
      ),
    );
  }

  /// The builder for the table.
  Widget createTableBuilder(BuildContext context, BoxConstraints constraints) {
    // Width cant be below 0 and must always fill the area.
    double maxWidth = max(max(tableSize.size.width, constraints.maxWidth), 0);

    // Is the table wider than it can be seen? -> Disables row swipes
    bool canScrollHorizontally = tableSize.size.width.ceil() > constraints.maxWidth.ceil();

    Widget table = createTableList(canScrollHorizontally, maxWidth);

    // Sticky headers are fixed above the table, non sticky headers are inserted into the list.
    if (model.tableHeaderVisible && model.stickyHeaders) {
      Widget header = SingleChildScrollView(
        physics: canScrollHorizontally ? null : const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        controller: headerHorizontalController,
        child: createHeaderRow(),
      );

      if (kIsWeb) {
        header = Scrollbar(
          controller: headerHorizontalController,
          child: header,
        );
      }

      return Column(
        children: [
          header,
          Expanded(
            child: table,
          ),
        ],
      );
    } else {
      return table;
    }
  }

  /// Creates the list of the table.
  Widget createTableList(bool canScrollHorizontally, double maxWidth) {
    return GestureDetector(
      onLongPressStart:
          onLongPress != null ? (details) => onLongPress?.call(-1, "", FlDummyCellEditor(), details) : null,
      child: NotificationListener<ScrollEndNotification>(
        onNotification: onInternalEndScroll,
        child: SingleChildScrollView(
          physics: canScrollHorizontally ? null : const NeverScrollableScrollPhysics(),
          controller: tableHorizontalController,
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: ScrollablePositionedList.builder(
              scrollDirection: Axis.vertical,
              itemScrollController: itemScrollController,
              itemBuilder: tableListItemBuilder,
              itemCount: _itemCount,
            ),
          ),
        ),
      ),
    );
  }

  /// The item builder of the scrollable positioned list.
  Widget tableListItemBuilder(BuildContext context, int pIndex) {
    int index = pIndex;

    if (model.tableHeaderVisible && !model.stickyHeaders) {
      index--;
      if (pIndex == 0) {
        return createHeaderRow();
      }
    }

    return FlTableRow(
      model: model,
      onEndEditing: onEndEditing,
      onValueChanged: onValueChanged,
      columnDefinitions: chunkData.columnDefinitions,
      onLongPress: onLongPress,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onAction: onAction,
      tableSize: tableSize,
      values: chunkData.data[index]!,
      recordFormats: chunkData.recordFormats?[model.name],
      index: index,
      isSelected: index == selectedRowIndex,
      disableEditors: disableEditors,
    );
  }

  /// Creates the header row.
  Widget createHeaderRow() {
    return FlTableHeaderRow(
      model: model,
      columnDefinitions: chunkData.columnDefinitions,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      tableSize: tableSize,
      onLongPress: onLongPress,
      sortDefinitions: chunkData.sortDefinitions,
    );
  }

  /// Notifies if the bottom of the table has been reached
  bool onInternalEndScroll(ScrollEndNotification notification) {
    if (notification.metrics.pixels > 0 && notification.metrics.atEdge) {
      if (notification.metrics.axis == Axis.vertical) {
        /// Scrolled to the bottom
        onEndScroll?.call();
      }
    }

    return true;
  }
}
