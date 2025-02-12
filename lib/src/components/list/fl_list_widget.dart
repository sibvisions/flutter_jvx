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

import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:json_dynamic_widget/json_dynamic_widget.dart';

import '../../../flutter_jvx.dart';
import '../base_wrapper/fl_stateful_widget.dart';
import 'fl_list_entry.dart';

typedef ListSlideActionFactory = List<SlidableAction> Function(BuildContext context, int row);
typedef ListScrollCallback = Function(ScrollNotification scrollNotification);
typedef ListScrollEndCallback = bool Function();

class FlListWidget extends FlStatefulWidget<FlTableModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// This style defines the marker for custom card templates
  static const String STYLE_TEMPLATE_MARKER = "f_template_";

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Callbacks
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Gets called when the list should refresh
  final Future<void> Function()? onRefresh;

  /// Gets called when the user scrolled to the edge of the list.
  final ListScrollEndCallback? onEndScroll;

  /// Gets called when the user scrolled the list.
  final ListScrollCallback? onScroll;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The data of the table.
  final DataChunk chunkData;

  /// The meta data of the table.
  final DalMetaData? metaData;

  /// Which slide actions are to be allowed to the row.
  final ListSlideActionFactory? slideActionFactory;

  /// The selected current row.
  final int selectedRowIndex;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlListWidget({
    super.key,
    required super.model,
    required this.chunkData,
    required this.metaData,
    this.slideActionFactory,
    this.selectedRowIndex = -1,
    this.onRefresh,
    this.onScroll,
    this.onEndScroll
  });

  @override
  State<FlListWidget> createState() => _FlListWidgetState();
}

class _FlListWidgetState extends State<FlListWidget> with TickerProviderStateMixin {
  final UniqueKey _center = UniqueKey();

  final _controller = ScrollController();

  final List<SlidableController> _slideController = [];

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      if (_controller.position.userScrollDirection ==
          ScrollDirection.forward) {
//        print("Down");
      } else if (_controller.position.userScrollDirection ==
          ScrollDirection.reverse) {
//        print("Up");
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  final GlobalKey<JsonWidgetExporterData> _exportKey = GlobalKey<JsonWidgetExporterData>();

  @override
  Widget build(BuildContext context) {

    Set<String> styles = widget.model.styles;

    String? tpl;
    String? tplEven;
    String? tplOdd;

    if (styles.isNotEmpty) {

      String? styledef;

      for (int i = 0; i < styles.length; i++)
      {
        styledef = styles.elementAt(i);

        if (styledef.startsWith(FlListWidget.STYLE_TEMPLATE_MARKER)) {
          styledef = styledef.substring(FlListWidget.STYLE_TEMPLATE_MARKER.length);
        }
      }

      tpl = styledef;
    }

    _closeSlidablesImmediate();
    _slideController.clear();

    return _wrapList(_wrapSlider(
        NotificationListener<ScrollNotification>(
            onNotification: (notification) => _onInternalEndScroll(notification),
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) => _onInternalScroll(notification),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: _controller,
                slivers: [
                  SliverList.separated(
                    separatorBuilder: (context, index) => Divider(height: 1.0, color: JVxColors.isLightTheme(context) ?  Colors.grey.shade300 : Colors.white70),
                    itemCount: widget.chunkData.data.length,
                    itemBuilder: (context, index) {
                      SlidableController? slideCtrl;

                      if (widget.slideActionFactory != null) {
                        if (index > _slideController.length - 1) {
                          slideCtrl = SlidableController(this);
                          _slideController.add(slideCtrl);
                        }
                        else {
                          slideCtrl = _slideController.elementAt(index);
                        }
                      }

                      if (widget.chunkData.data[index] != null &&
                          widget.chunkData.data[index]!.last == "DISMISSED") {
                        return Container();
                      }

                      return ListTile(
                        minTileHeight: 10,
                        contentPadding: const EdgeInsets.all(0),
                        minVerticalPadding: 0,
                        title: FlListEntry(
                            model: widget.model,
                            columnDefinitions: widget.chunkData.columnDefinitions,
                            slideController: slideCtrl,
                            slideActionFactory: widget.slideActionFactory,
                            template: tpl,
                            onDismissed: (index) {
                              SlidableController ctrl = _slideController.elementAt(index);
                              ctrl.close(duration: const Duration(milliseconds: 0));
                              setState(() {
                                List<dynamic>? record = widget.chunkData.data[index];

                                if (record != null) {
                                  record[record.length - 1] = "DISMISSED";
                                }

                                _slideController.removeAt(index);

                                HapticFeedback.mediumImpact();
                              });
                            },
                            values: widget.chunkData.data[index]!,
                            recordFormat: widget.chunkData.recordFormats?[widget.model.name],
                            index: index,
                            isSelected: index == widget.selectedRowIndex),
                      );
                    },
                  ),
                ],
              )
          )
        )
      )
    );
  }

  Widget _wrapList(Widget list) {
    if (widget.onRefresh != null && widget.model.isEnabled) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh!,
        child: list,
        notificationPredicate: (notification) => notification.depth == 0,
      );
    }

    return list;
  }

  Widget _wrapSlider(Widget list) {
    if (widget.slideActionFactory != null) {
      return SlidableAutoCloseBehavior(
        closeWhenOpened: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
//          onLongPressStart: widget.onLongPress != null && widget.model.isEnabled ? (details) {
          //widget.onLongPress?.call(-1, "", FlDummyCellEditor(), details.globalPosition);

//            _closeSlidables();
//          }
//            : null,
          onTap: () => _closeSlidables(),
          child: list,
        ),
      );
    }

    return list;
  }

  /// Closes all slidables immediately without delay
  void _closeSlidablesImmediate() {
    _closeSlidables(null, const Duration(milliseconds:  0));
  }

  /// Closes all slidables with given or default delay. If an [event] is given
  /// the position of the table widget shouldn't collide with event position.
  /// Only events outside the table widget will be recognized
  void _closeSlidables([PointerEvent? event, Duration? duration]) {
    if (!mounted) return;

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

  /// Notifies if the bottom of the list has been reached
  bool _onInternalEndScroll(ScrollNotification notification) {
    // 25 is a grace value.
    if (widget.model.isEnabled &&
        notification.metrics.extentAfter < 25 &&
        notification.metrics.axis == Axis.vertical) {
      /// Scrolled to the bottom
      return widget.onEndScroll?.call() == true;
    }

    return false;
  }

  bool _onInternalScroll(ScrollNotification notification) {
    widget.onScroll?.call(notification);

    // Let it bubble upwards to our end notification listener!
    return false;
  }

}