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
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../components.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/data/data_book.dart';
import '../../model/data/subscriptions/data_chunk.dart';
import '../base_wrapper/fl_stateful_widget.dart';
import '../editor/cell_editor/fl_dummy_cell_editor.dart';
import '../editor/cell_editor/i_cell_editor.dart';
import 'fl_table_header_row.dart';
import 'fl_table_row.dart';

typedef TableLongPressCallback = void Function(
    int rowIndex, String column, ICellEditor cellEditor, Offset pGlobalPosition);
typedef TableTapCallback = void Function(int rowIndex, String column, ICellEditor cellEditor);
typedef TableHeaderTapCallback = void Function(String column);
typedef TableValueChangedCallback = void Function(dynamic value, int row, String column);
typedef TableSlideActionFactory = List<SlidableAction> Function(int pRowIndex);

class FlTableWidget extends FlStatefulWidget<FlTableModel> {
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

  /// Gets called the name of the column pressed.
  final TableHeaderTapCallback? onHeaderTap;

  /// Gets called the name of the column pressed.
  final TableHeaderTapCallback? onHeaderDoubleTap;

  /// Gets called when the user long presses the table or a row/column.
  final TableLongPressCallback? onLongPress;

  /// Gets called when the user scrolled to the edge of the table.
  final VoidCallback? onEndScroll;

  /// Gets called when the user scrolled the table.
  final Function(ScrollNotification pScrollNotification)? onScroll;

  /// Gets called when the list should refresh
  final Future<void> Function()? onRefresh;

  // Fields

  /// Contains all relevant table size information.
  final TableSize tableSize;

  /// The selected current row.
  final int selectedRowIndex;

  /// The selected column;
  final String? selectedColumn;

  /// The data of the table.
  final DataChunk chunkData;

  /// If a button is shown at the bottom.
  final bool showFloatingButton;

  /// The action the floating button calls.
  final VoidCallback? floatingOnPress;

  /// Which slide actions are to be allowed to the row.
  final TableSlideActionFactory? slideActionFactory;

  /// The meta data of the table.
  final DalMetaData? metaData;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlTableWidget({
    super.key,
    required super.model,
    required this.chunkData,
    required this.tableSize,
    required this.metaData,
    this.tableHorizontalController,
    this.headerHorizontalController,
    this.selectedRowIndex = -1,
    this.selectedColumn,
    this.onTap,
    this.onHeaderTap,
    this.onHeaderDoubleTap,
    this.onLongPress,
    this.onEndScroll,
    this.onScroll,
    this.onRefresh,
    this.slideActionFactory,
    this.itemScrollController,
    this.onEndEditing,
    this.onValueChanged,
    this.showFloatingButton = false,
    this.floatingOnPress,
  });

  @override
  State<FlTableWidget> createState() => _FlTableWidgetState();
}

class _FlTableWidgetState extends State<FlTableWidget> {
  /// How many items the scrollable list should build.
  int get _itemCount {
    int itemCount = widget.chunkData.data.length;

    if (widget.model.tableHeaderVisible && !widget.model.stickyHeaders) {
      itemCount += 1;
    }

    return itemCount;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [LayoutBuilder(builder: createTableBuilder)];

    if (widget.showFloatingButton && widget.floatingOnPress != null) {
      children.add(createFloatingButton(context));
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(
          width: widget.tableSize.borderWidth,
          color: Theme.of(context).colorScheme.primary,
        ),
        color: Theme.of(context).colorScheme.background,
      ),
      child: ClipRRect(
        // The clip rect is there to stop the rendering of the children.
        // Otherwise the children would clip the border of the parent container.
        borderRadius: BorderRadius.circular(4.0 - widget.tableSize.borderWidth),
        child: Stack(
          children: children,
        ),
      ),
    );
  }

  /// Creates the floating button that floats above the table on the bottom right
  Positioned createFloatingButton(BuildContext context) {
    return Positioned(
      right: 10,
      bottom: 10,
      child: FloatingActionButton(
        heroTag: null,
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: widget.floatingOnPress,
        child: FaIcon(
          FontAwesomeIcons.squarePlus,
          color: widget.model.foreground ?? Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }

  /// The builder for the table.
  Widget createTableBuilder(BuildContext context, BoxConstraints constraints) {
    // Width cant be below 0 and must always fill the area.
    double maxWidth = max(max(widget.tableSize.width, constraints.maxWidth), 0);

    // Is the table wider than it can be seen? -> Disables row swipes
    bool canScrollHorizontally = widget.tableSize.width.ceil() > constraints.maxWidth.ceil();

    Widget table = createTableList(canScrollHorizontally, maxWidth);

    if (widget.onRefresh != null && widget.model.isEnabled) {
      table = RefreshIndicator(
        onRefresh: widget.onRefresh!,
        child: table,
        notificationPredicate: (notification) => notification.depth == 1,
      );
    }

    table = SlidableAutoCloseBehavior(
      closeWhenOpened: true,
      child: GestureDetector(
        onLongPressStart: widget.onLongPress != null && widget.model.isEnabled
            ? (details) => widget.onLongPress?.call(-1, "", FlDummyCellEditor(), details.globalPosition)
            : null,
        child: NotificationListener<ScrollEndNotification>(
          onNotification: onInternalEndScroll,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              widget.onScroll?.call(notification);
              // Let it bubble upwards to our end notification listener!
              return false;
            },
            child: table,
          ),
        ),
      ),
    );

    // Sticky headers are fixed above the table, non sticky headers are inserted into the list.
    if (widget.model.tableHeaderVisible && widget.model.stickyHeaders) {
      Widget header = SingleChildScrollView(
        physics: canScrollHorizontally ? null : const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        controller: widget.headerHorizontalController,
        child: createHeaderRow(),
      );

      if (kIsWeb) {
        header = Scrollbar(
          controller: widget.headerHorizontalController,
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
    return SingleChildScrollView(
      physics: canScrollHorizontally ? null : const NeverScrollableScrollPhysics(),
      controller: widget.tableHorizontalController,
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Stack(
          children: [
            ScrollablePositionedList.builder(
              scrollDirection: Axis.vertical,
              physics: const AlwaysScrollableScrollPhysics(),
              itemScrollController: widget.itemScrollController,
              itemBuilder: (context, index) => tableListItemBuilder(context, index, canScrollHorizontally),
              itemCount: _itemCount,
            )
          ],
        ),
      ),
    );
  }

  /// The item builder of the scrollable positioned list.
  Widget tableListItemBuilder(BuildContext context, int pIndex, bool canScrollHorizontally) {
    int index = pIndex;

    if (_itemCount > widget.chunkData.data.length) {
      index--;
    }

    if (index < 0) {
      return createHeaderRow();
    } else if (index > widget.chunkData.data.length - 1) {
      // When rebuilding the table, the item count can still be an old one while the data is already updated.
      return const SizedBox(height: 0);
    }

    return FlTableRow(
      model: widget.model,
      onEndEditing: widget.onEndEditing,
      onValueChanged: widget.onValueChanged,
      columnDefinitions: widget.chunkData.columnDefinitions,
      onLongPress: widget.onLongPress,
      onTap: widget.onTap,
      slideActionFactory: !canScrollHorizontally ? widget.slideActionFactory : null,
      tableSize: widget.tableSize,
      values: widget.chunkData.data[index]!,
      recordFormats: widget.chunkData.recordFormats?[widget.model.name],
      recordReadOnly: widget.chunkData.dataReadOnly?[index],
      index: index,
      isSelected: index == widget.selectedRowIndex,
      selectedColumn: widget.selectedColumn,
    );
  }

  /// Creates the header row.
  Widget createHeaderRow() {
    return FlTableHeaderRow(
      model: widget.model,
      columnDefinitions: widget.chunkData.columnDefinitions,
      onTap: widget.onHeaderTap,
      onDoubleTap: widget.onHeaderDoubleTap,
      tableSize: widget.tableSize,
      onLongPress: widget.onLongPress,
      sortDefinitions: widget.metaData?.sortDefinitions,
    );
  }

  /// Notifies if the bottom of the table has been reached
  bool onInternalEndScroll(ScrollEndNotification notification) {
    // 25 is a grace value.
    if (widget.model.isEnabled &&
        notification.metrics.extentAfter < 25 &&
        notification.metrics.atEdge &&
        notification.metrics.axis == Axis.vertical) {
      /// Scrolled to the bottom
      widget.onEndScroll?.call();
    }

    return true;
  }
}
