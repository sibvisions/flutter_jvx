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
  final TableScrollCallback? onScroll;

  /// Gets called when the list should refresh
  final Future<void> Function()? onRefresh;

  /// The action the floating button calls.
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
  int? selectedRowIndex;

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
        position.isScrollingNotifier.addListener(_scrollUpdate);
      },
      onDetach: (position) {
        position.isScrollingNotifier.removeListener(_scrollUpdate);
      }
    );
    _observerController = SliverObserverController(controller: _scrollController);

    selectedRowIndex = -1;
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

    if (_sliverContext != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _scrollToSelected(_sliverContext!);
      });
    }

    List<Widget> children = [LayoutBuilder(builder: createTableBuilder)];

    if (widget.onFloatingPress != null) {
      children.add(createFloatingButton(context));
    }

    bool noBorder = widget.model.styles.contains(FlTableWidget.STYLE_NO_BORDER);

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
  Widget createTableBuilder(BuildContext context, BoxConstraints constraints) {
    // Width cant be below 0 and must always fill the area.
    double maxWidth = max(max(widget.tableSize.sumColumnWidth, constraints.maxWidth), 0);

    // Is the table wider than it can be seen? -> Disables row swipes
    bool canScrollHorizontally = widget.tableSize.sumColumnWidth.toPrecision(1) > constraints.maxWidth.toPrecision(1);

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
        behavior: HitTestBehavior.opaque,
        onLongPressStart: widget.onLongPress != null && widget.model.isEnabled
            ? (details) {
                widget.onLongPress?.call(-1, "", FlDummyCellEditor(), details.globalPosition);

                _closeSlidables();
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

                          if (widget.model.json["scoll_force"] == true) {
                            //force scrolling
                            selectedRowIndex = -1;
                          }

                          SchedulerBinding.instance.addPostFrameCallback((_) {
                            _scrollToSelected(_sliverContext!);
                          });
                        }

                        return tableListItemBuilder(context, index, canScrollHorizontally);
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
      onTap: widget.onTap,
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
  Widget createHeaderRow() {
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

  void _scrollUpdate() {
    widget.model.json["scroll_offset"] = _scrollController!.offset;
  }

  /// Scrolls the table to the selected row if it is not visible.
  /// Can only be called in the post frame callback as the scroll controller
  /// otherwise has not yet been updated with the most recent items.
  Future<void> _scrollToSelected(BuildContext sliverContext) async {
    if (widget.chunkData.data.isEmpty || widget.selectedRowIndex < 0) {
      if (widget.selectedRowIndex < 0) {
        selectedRowIndex = -1;
      }

      return;
    }

    widget.model.json.remove("scoll_force");

    if (selectedRowIndex == widget.selectedRowIndex) {
      return;
    }

    final result = await _observerController.dispatchOnceObserve(
      sliverContext: sliverContext,
      isDependObserveCallback: false,
      isForce: true,
    );

    final observeResult = result.observeAllResult[sliverContext];

    //wrong results
    if (observeResult is! ListViewObserveModel) {
      return;
    }

    final resultMap = observeResult.displayingChildModelMap;
    final targetResult = resultMap[widget.selectedRowIndex];
    final displayPercentage = targetResult?.displayPercentage ?? 0;

    //already fully visible -> don't scroll
    if (displayPercentage == 1) return;

    selectedRowIndex = widget.selectedRowIndex;

    bool isAtTopItem = false;

    if (targetResult != null) {
      isAtTopItem = targetResult.leadingMarginToViewport <= 0;
    }
    else {
      final displayingChildModelList = observeResult.displayingChildModelList;

      if (displayingChildModelList.isNotEmpty) {
        final firstItem = displayingChildModelList.first;
        isAtTopItem = firstItem.index > widget.selectedRowIndex;
      }
    }

    widget.model.json["scoll_force"] = true;

    await _observerController.animateTo(
      sliverContext: _sliverContext,
      duration: kThemeAnimationDuration,
      isFixedHeight: true,
      alignment: 0.5,
      curve: Curves.easeInOut,
      index: widget.selectedRowIndex,
      offset: (targetOffset) {
        var _obj = ObserverUtils.findRenderObject(_sliverContext);

        if (_obj == null || _obj is! RenderSliver) {
          return 0;
        }

        return (_obj.geometry?.paintExtent ?? 0) * 0.5;
      },
    );
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
