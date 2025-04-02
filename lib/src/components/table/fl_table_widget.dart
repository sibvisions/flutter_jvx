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

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:scrollview_observer/src/sliver/models/sliver_observer_observe_result_model.dart';

import '../../../flutter_jvx.dart';
import '../../util/extensions/double_extensions.dart';
import '../base_wrapper/fl_stateful_widget.dart';
import '../editor/cell_editor/fl_dummy_cell_editor.dart';
import '../editor/cell_editor/i_cell_editor.dart';
import 'fl_table_header_row.dart';
import 'fl_table_row.dart';

typedef TableLongPressCallback = void Function(int rowIndex, String column, ICellEditor cellEditor, Offset pGlobalPosition);
typedef TableTapCallback = void Function(int rowIndex, String column, ICellEditor cellEditor);
typedef TableHeaderTapCallback = void Function(String column);
typedef TableValueChangedCallback = void Function(dynamic value, int row, String column);
typedef TableSlideActionFactory = List<SlidableAction> Function(BuildContext context, int row);
typedef TableScrollCallback = Function(ScrollNotification scrollNotification);

class FlTableWidget extends FlStatefulWidget<FlTableModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Callbacks
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The callback if a value has ended beeing changed in the table.
  final TableValueChangedCallback? onEndEditing;

  /// The callback if a value has been changed in the table.
  final TableValueChangedCallback? onValueChanged;

  /// The callback for cell taps.
  final TableTapCallback? onTap;

  /// The callback for header taps.
  final TableHeaderTapCallback? onHeaderTap;

  /// The callback for table column double taps.
  final TableHeaderTapCallback? onHeaderDoubleTap;

  /// The callback for long-press on cells.
  final TableLongPressCallback? onLongPress;

  /// The callback in case of user scrolled to the edge of the table.
  final VoidCallback? onEndScroll;

  /// The callback in case of user scrolled the table.
  final TableScrollCallback? onScroll;

  /// The callback for data refresh
  final Future<void> Function()? onRefresh;

  /// The callback for floating button (no callback means no floating button)
  final VoidCallback? onFloatingPress;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The style name for no border
  static const String STYLE_NO_BORDER = "f_table_noborder";

  /// The scroll controller for the table.
  final ScrollController? tableHorizontalController;

  /// The scroll controller for the headers if they are set to sticky.
  final ScrollController? headerHorizontalController;

  /// Which slide actions are to be allowed to the row.
  final TableSlideActionFactory? slideActionFactory;

  /// The data of the table.
  final DataChunk chunkData;

  /// The meta data of the table.
  final DalMetaData? metaData;

  /// Contains all relevant table size information.
  final TableSize tableSize;

  /// The selected current row.
  final int selectedRowIndex;

  /// The selected column;
  final String? selectedColumn;

  /// Whether an initial scroll to selected record should happen
  final bool initialScrollToSelected;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlTableWidget({
    super.key,
    required super.model,
    required this.chunkData,
    required this.tableSize,
    required this.metaData,
    this.selectedRowIndex = -1,
    this.selectedColumn,
    this.initialScrollToSelected = true,
    this.tableHorizontalController,
    this.headerHorizontalController,
    this.slideActionFactory,
    this.onTap,
    this.onHeaderTap,
    this.onHeaderDoubleTap,
    this.onLongPress,
    this.onEndScroll,
    this.onScroll,
    this.onRefresh,
    this.onEndEditing,
    this.onValueChanged,
    this.onFloatingPress
  });

  @override
  State<FlTableWidget> createState() => _FlTableWidgetState();
}

class _FlTableWidgetState extends State<FlTableWidget> with TickerProviderStateMixin {
  /// The current sliver context
  BuildContext? _sliverContext;

  /// The item scroll controller.
  late ScrollController? _scrollController;

  /// The controller for the view observer
  late final SliverObserverController _observerController;

  /// All cached slidable controller
  final List<SlidableController> _slideController = [];

  /// The currently selected row index
  int selectedRowIndex = -1;

  /// Whether the table should scroll to the selected row
  bool _scrollToSelected = true;

  /// Whether it's the first selection
  bool firstSelection = false;

  /// How many items the scrollable list should build.
  int get _itemCount {
    int itemCount = widget.chunkData.data.length;

    if (widget.model.tableHeaderVisible && !widget.model.stickyHeaders) {
      itemCount += 1;
    }

    return itemCount;
  }


  @override
  void initState() {
    super.initState();

    FlutterUI.registerGlobalSubscription(GlobalSubscription(subbedObj: this, onTap: _closeSlidables));

    _scrollController = ScrollController(
      initialScrollOffset: widget.model.json["scroll_offset"] ?? 0,
      onAttach: (position) {
        _scrollUpdate(position);

        position.isScrollingNotifier.addListener(_scrollUpdate);
      },
      onDetach: (position) {
        position.isScrollingNotifier.removeListener(_scrollUpdate);

        _scrollUpdate(position);
      }
    );
    _observerController = SliverObserverController(controller: _scrollController);

    _scrollToSelected = widget.initialScrollToSelected;

    if (_scrollToSelected) {
      selectedRowIndex = -1;
    }
    else {
      selectedRowIndex = widget.selectedRowIndex;
    }
  }

  @override
  void didUpdateWidget(FlTableWidget oldWidget ) {
    super.didUpdateWidget(oldWidget);

    _scrollToSelected |= widget.initialScrollToSelected;

    if (_scrollToSelected) {
      selectedRowIndex = -1;
    }
  }

  @override
  void dispose() {
    super.dispose();

    FlutterUI.disposeGlobalSubscription(this);

    _scrollController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _closeSlidablesImmediate();
    _slideController.clear();

    List<Widget> children = [LayoutBuilder(builder: _createTable)];

    if (widget.onFloatingPress != null) {
      children.add(createFloatingButton(context));
    }

    bool noBorder = widget.model.styles.contains(FlTableWidget.STYLE_NO_BORDER);

    if (_sliverContext != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _scrollTo(widget.selectedRowIndex);
      });
    }

    if (noBorder) {
      return Stack(children: children);
    }
    else {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(
            width: widget.tableSize.borderWidth,
            color: JVxColors.COMPONENT_BORDER,
          ),
          color: Theme.of(context).colorScheme.surface,
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
  }

  /// Creates the floating button that floats above the table on the bottom right
  Positioned createFloatingButton(BuildContext context) {
    return Positioned(
      right: 10,
      bottom: 10,
      child: FloatingActionButton(
        heroTag: null,
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: widget.onFloatingPress,
        child: FaIcon(
          FontAwesomeIcons.squarePlus,
          color: widget.model.foreground ?? Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }

  /// The builder for the table.
  Widget _createTable(BuildContext context, BoxConstraints constraints) {
    // Width cant be below 0 and must always fill the area.
    double maxWidth = max(max(widget.tableSize.sumColumnWidth, constraints.maxWidth), 0);

    // Is the table wider than it can be seen? -> Disables row swipes
    bool canScrollHorizontally = widget.tableSize.sumColumnWidth.toPrecision(1) > constraints.maxWidth.toPrecision(1);

    Widget table = _createRecordList(canScrollHorizontally, maxWidth);

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
        behavior: HitTestBehavior.opaque,
        onLongPressStart: widget.onLongPress != null && widget.model.isEnabled
            ? (details) {
                _closeSlidables();

                _forwardLongPress(details.globalPosition);
              }
            : null,
        onTap: () => _closeSlidables(),
        child: NotificationListener<ScrollEndNotification>(
          onNotification: _onInternalEndScroll,
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
        child: _createHeaderRow(),
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

  /// Creates the list of records.
  Widget _createRecordList(bool canScrollHorizontally, double maxWidth) {
    return SingleChildScrollView(
      physics: canScrollHorizontally ? null : const NeverScrollableScrollPhysics(),
      controller: widget.tableHorizontalController,
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Stack(
          children: [
            FixedSliverViewObserver(
              controller: _observerController,
              child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  controller: _scrollController,
                  slivers: [
                    SliverList.builder(
                      itemBuilder: (context, index) {
                        if (_sliverContext != context) {
                          _sliverContext = context;

                          SchedulerBinding.instance.addPostFrameCallback((_) {
                            _scrollTo(widget.selectedRowIndex);
                          });
                        }

                        return _tableItem(context, index, canScrollHorizontally);
                      },
                      itemCount: _itemCount,
                    )
                  ]
                )
              )
          ],
        ),
      ),
    );
  }

  /// The item builder of the scrollable positioned list.
  Widget _tableItem(BuildContext context, int pIndex, bool canScrollHorizontally) {
    int index = pIndex;

    if (_itemCount > widget.chunkData.data.length) {
      index--;
    }

    if (index < 0) {
      return _createHeaderRow();
    } else if (index > widget.chunkData.data.length - 1) {
      // When rebuilding the table, the item count can still be an old one while the data is already updated.
      return const SizedBox(height: 0);
    }

    SlidableController? slideCtrl;

    if (!canScrollHorizontally && widget.slideActionFactory != null) {
      if (index > _slideController.length - 1) {
        slideCtrl = SlidableController(this);
        _slideController.add(slideCtrl);
      }
      else {
        slideCtrl = _slideController.elementAt(index);
      }
    }

    if (widget.chunkData.getRecordStatusRaw(index)?.contains("DISMISSED") == true) {
      return Container();
    }

    return FlTableRow(
      model: widget.model,
      onEndEditing: widget.onEndEditing,
      onValueChanged: widget.onValueChanged,
      columnDefinitions: widget.chunkData.columnDefinitions,
      onLongPress: widget.onLongPress,
      onTap: (rowIndex, column, cellEditor) {
        if (widget.onTap != null) {
          widget.onTap!(rowIndex, column, cellEditor);
        }

        _scrollToSelected = true;
      },
      slideController: slideCtrl,
      slideActionFactory: !canScrollHorizontally ? widget.slideActionFactory : null,
      onDismissed: (index) {
        String? status = widget.chunkData.getRecordStatusRaw(index);

        if (status != null && !status.contains("DISMISSED")) {
          if (_slideController.length > index) {
            SlidableController ctrl = _slideController.elementAt(index);
            ctrl.close(duration: const Duration(milliseconds: 0));

            _slideController.removeAt(index);
          }

          widget.chunkData.setStatusRaw(index, "DISMISSED");

          HapticFeedback.mediumImpact();

          setState(() {});
        }
      },
      tableSize: widget.tableSize,
      values: widget.chunkData.data[index]!,
      recordFormat: widget.chunkData.recordFormats?[widget.model.name]?.rowFormats[index],
      recordReadOnly: widget.chunkData.dataReadOnly?[index],
      index: index,
      isSelected: index == widget.selectedRowIndex,
      selectedColumn: widget.selectedColumn,
    );
  }

  /// Creates the header row.
  Widget _createHeaderRow() {
    return FlTableHeaderRow(
      model: widget.model,
      columnDefinitions: widget.chunkData.columnDefinitions,
      onTap: (String column) {
        _closeSlidablesImmediate();

        if (widget.onHeaderTap != null) {
          widget.onHeaderTap!(column);
        }
      },
    onDoubleTap: (column) {
      _closeSlidablesImmediate();

      if (widget.onHeaderDoubleTap != null) {
        widget.onHeaderDoubleTap!(column);
      }

    },
      tableSize: widget.tableSize,
      onLongPress: widget.onLongPress,
      sortDefinitions: widget.metaData?.sortDefinitions,
    );
  }

  /// Notifies if the bottom of the table has been reached
  bool _onInternalEndScroll(ScrollEndNotification notification) {
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

  /// Closes all slidables immediately without delay
  void _closeSlidablesImmediate() {
    _closeSlidables(null, const Duration(milliseconds:  0));
  }

  /// Closes all slidables with given or default delay. If an [event] is given
  /// the position of the table widget shouldn't collide with event position.
  /// Only events outside the table widget will be recognized
  void _closeSlidables([PointerEvent? event, Duration? duration]) {
    if (!mounted || _slideController.isEmpty) {
      return;
    }

    bool collide = false;

    if (event != null) {
      final RenderBox table = context.findRenderObject() as RenderBox;

      final size1 = table.size;
      final size2 = event.size;

      final position1 = table.localToGlobal(Offset.zero);
      final position2 = event.position;

      collide = (position1.dx < position2.dx + size2 &&
          position1.dx + size1.width > position2.dx &&
          position1.dy < position2.dy + size2 &&
          position1.dy + size1.height > position2.dy);
    }

    if (!collide) {
      _slideController.toList(growable: false).forEach((element) {
        if (duration != null) {
          element.close(duration: duration);
        }
        else {
          element.close();
        }
      });
    }
  }

  /// Updates the cached scroll position (in the model) to re-use it if necessary on re-creation
  void _scrollUpdate([ScrollPosition? position]) {
    widget.model.json["scroll_offset"] = position?.pixels ?? _scrollController!.offset;
  }

  /// Scrolls the table to the selected row if it is not visible.
  /// Can only be called in the post frame callback as the scroll controller
  /// otherwise has not yet been updated with the most recent items.
  Future<void> _scrollTo(int rowIndex) async {
    if (_sliverContext == null) {
      return;
    }

    if (widget.chunkData.data.isEmpty || rowIndex < 0) {
      if (rowIndex < 0) {
        selectedRowIndex = -1;
      }

      return;
    }

    if (!_scrollToSelected) {
      return;
    }

    _scrollToSelected = false;

    if (selectedRowIndex == rowIndex) {
      return;
    }

    final result = await _observerController.dispatchOnceObserve(
      sliverContext: _sliverContext!,
      isDependObserveCallback: false,
      isForce: true,
    );

    final observeResult = result.observeAllResult[_sliverContext];

    //wrong results
    if (observeResult is! ListViewObserveModel) {
      //try again
      _scrollToSelected = true;

      return;
    }

    final resultMap = observeResult.displayingChildModelMap;
    final targetResult = resultMap[rowIndex];
    final displayPercentage = targetResult?.displayPercentage ?? 0;

    //already fully visible -> don't scroll
    if (displayPercentage == 1) return;

    selectedRowIndex = rowIndex;

    var obj = ObserverUtils.findRenderObject(_sliverContext);

    if (obj == null || obj is! RenderSliver
        || (obj.geometry?.paintExtent ?? 0) == 0) {

      selectedRowIndex = -1;
      _scrollToSelected = true;

      return;
    }

    unawaited(_observerController.animateTo(
      sliverContext: _sliverContext,
      duration: kThemeAnimationDuration,
      isFixedHeight: true,
      alignment: 0.5,
      curve: Curves.easeInOut,
      index: rowIndex,
      offset: (targetOffset) {
        var obj = ObserverUtils.findRenderObject(_sliverContext);

        if (obj == null || obj is! RenderSliver) {
          return 0;
        }

        if ((obj.geometry?.paintExtent ?? 0) == 0) {
          selectedRowIndex = -1;
          _scrollToSelected = true;

          return 0;
        }

        return (obj.geometry?.paintExtent ?? 0) * 0.5;
      },
    ));
  }

  Future<void> _forwardLongPress(Offset globalPosition) async {
    final result = await _observerController.dispatchOnceObserve(
      sliverContext: _sliverContext!,
      isDependObserveCallback: false,
      isForce: true,
    );

    final observeResult = result.observeAllResult[_sliverContext];

    //wrong results
    if (observeResult is! ListViewObserveModel) {
      widget.onLongPress?.call(-1, "", FlDummyCellEditor(), globalPosition);

      return;
    }

    final resultMap = observeResult.displayingChildModelList;

    for (ListViewObserveDisplayingChildModel element in resultMap) {
      Offset tile = element.renderObject.localToGlobal(Offset.zero);

      Rect rectTile = Rect.fromLTWH(tile.dx, tile.dy, element.renderObject.size.width, element.renderObject.size.height);

      if (rectTile.contains(globalPosition)) {
        double xPos = tile.dx;

        String? sFoundColumn;

        for (int i = 0; i < widget.model.columnNames.length && sFoundColumn == null; i++) {
          xPos += widget.tableSize.columnWidths[widget.model.columnNames[i]] ?? 0;

          if (globalPosition.dx < xPos) {
            sFoundColumn = widget.model.columnNames[i];
          }
        }

        widget.onLongPress?.call(element.index, sFoundColumn ?? "", FlDummyCellEditor(), globalPosition);

        return;
      }
    }

    //We try to find the column name
    String? sFoundColumn;

    if (resultMap.isNotEmpty) {
      double xPos = resultMap[0].renderObject.localToGlobal(Offset.zero).dx;

      String? sFoundColumn;

      for (int i = 0; i < widget.model.columnNames.length && sFoundColumn == null; i++) {
        xPos += widget.tableSize.columnWidths[widget.model.columnNames[i]] ?? 0;

        if (globalPosition.dx < xPos) {
          sFoundColumn = widget.model.columnNames[i];
        }
      }
    }

    widget.onLongPress?.call(-1, sFoundColumn ?? "", FlDummyCellEditor(), globalPosition);
  }
}

class FixedSliverViewObserver extends SliverViewObserver {
  const FixedSliverViewObserver({
    super.key,
    required super.child,
    super.tag,
    super.controller,
    super.sliverListContexts,
    super.sliverContexts,
    super.onObserveAll,
    super.onObserve,
    super.onObserveViewport,
    super.leadingOffset,
    super.dynamicLeadingOffset,
    super.customOverlap,
    super.toNextOverPercent,
    super.scrollNotificationPredicate,
    super.autoTriggerObserveTypes,
    super.triggerOnObserveType,
    super.customHandleObserve,
    super.extendedHandleObserve
  });

  @override
  State<SliverViewObserver> createState() => FixMixViewObserverState();
}

class FixMixViewObserverState extends MixViewObserverState {

    @override
    SliverObserverHandleContextsResultModel<ObserveModel>? handleContexts({
      bool isForceObserve = false,
      bool isFromObserveNotification = false,
      bool isDependObserveCallback = true,
      bool isIgnoreInnerCanHandleObserve = true,
    }) {
      //means: disposed
      if (innerSliverListeners == null) {
        return null;
      }

      return super.handleContexts(
        isForceObserve: isForceObserve,
        isFromObserveNotification: isFromObserveNotification,
        isDependObserveCallback: isDependObserveCallback,
        isIgnoreInnerCanHandleObserve: isIgnoreInnerCanHandleObserve);
    }

  }
