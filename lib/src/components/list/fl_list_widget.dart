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

import 'dart:ui';

import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:json_dynamic_widget/json_dynamic_widget.dart';

import '../../../flutter_jvx.dart';
import '../base_wrapper/fl_stateful_widget.dart';
import '../editor/cell_editor/i_cell_editor.dart';
import 'fl_list_entry.dart';

typedef ListTapCallback = void Function(int rowIndex);
typedef ListSlideActionFactory = List<SlidableAction> Function(BuildContext context, int row);
typedef ListScrollCallback = Function(ScrollNotification scrollNotification);
typedef ListScrollEndCallback = bool Function();

class FlListWidget extends FlStatefulWidget<FlTableModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// This style defines the marker for custom card templates
  static const String STYLE_TEMPLATE_MARKER = "f_template_";

  /// With this style list will show card items
  static const String STYLE_AS_CARD = "f_as_card";

  /// With this style list entry will show an arrow
  static const String STYLE_WITH_ARROW = "f_with_arrow";

  /// With this style list entry will be vertically top aligned
  static const String STYLE_VALIGN_TOP = "f_valign_top";

  /// With this style list entry will be vertically bottom aligned
  static const String STYLE_VALIGN_BOTTOM = "f_valign_bottom";

  /// The style for column count per text row
  static const String STYLE_COLUMN_COUNT = "f_list_columncount_";

  /// The style for column separation character
  static const String STYLE_COLUMN_SEPARATOR = "f_list_columnseparator_";

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Callbacks
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Gets called when the list should refresh
  final Future<void> Function()? onRefresh;

  /// Gets called when the user scrolled to the edge of the list.
  final ListScrollEndCallback? onEndScroll;

  /// Gets called when the user scrolled the list.
  final ListScrollCallback? onScroll;

  final ListTapCallback? onTap;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The data of the table.
  final DataChunk chunkData;

  /// The meta data of the table.
  final DalMetaData? metaData;

  /// Which slide actions are to be allowed to the row.
  final ListSlideActionFactory? slideActionFactory;

  /// the cell editors
  final Map<String, ICellEditor> cellEditors;

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
    required this.cellEditors,
    this.slideActionFactory,
    this.selectedRowIndex = -1,
    this.onRefresh,
    this.onScroll,
    this.onEndScroll,
    this.onTap
  });

  @override
  State<FlListWidget> createState() => _FlListWidgetState();
}

class _FlListWidgetState extends State<FlListWidget> with TickerProviderStateMixin {
  final _controller = ScrollController();

  final List<SlidableController> _slideController = [];

  @override
  void initState() {
    super.initState();

    FlutterUI.registerGlobalSubscription(GlobalSubscription(subbedObj: this, onTap: _closeSlidables));
    /*
    _controller.addListener(() {
      if (_controller.position.userScrollDirection ==
        ScrollDirection.forward) {
        print("Down");
      } else if (_controller.position.userScrollDirection ==
        ScrollDirection.reverse) {
        print("Up");
      }
    });
    */
  }

  @override
  void dispose() {
    super.dispose();

    FlutterUI.disposeGlobalSubscription(this);
  }

  @override
  Widget build(BuildContext context) {
    Set<String> styles = widget.model.styles;

    String? tpl;

    bool asCard = false;
    bool withArrow = false;
    MainAxisAlignment? vAlign;

    Map<int, int>? mapColumnsPerRow;
    List<String>? columnSeparator;

    if (styles.isNotEmpty) {

      String? styleDef;

      for (int i = 0; i < styles.length; i++)
      {
        styleDef = styles.elementAt(i);

        if (styleDef.startsWith(FlListWidget.STYLE_TEMPLATE_MARKER)) {
          styleDef = styleDef.substring(FlListWidget.STYLE_TEMPLATE_MARKER.length);

          tpl = styleDef;
        }
        else if (!asCard && styleDef == FlListWidget.STYLE_AS_CARD) {
          asCard = true;
        }
        else if (styleDef.startsWith(FlListWidget.STYLE_COLUMN_COUNT)) {
          //e.g. 1_2_3 (means first row = 1 column, second row = 2 columns, third row = 3 columns)
          styleDef = styleDef.substring(FlListWidget.STYLE_COLUMN_COUNT.length);

          mapColumnsPerRow = {};
          List<String> colCount = styleDef.split("_");

          for (int i = 0; i < colCount.length; i++) {
            mapColumnsPerRow[i] = int.parse(colCount[i]);
          }
        }
        else if (styleDef.startsWith(FlListWidget.STYLE_COLUMN_SEPARATOR)) {
          //e.g. :_,_%20,%20 (first separator = colon, second = comma, third = space colon space)
          styleDef = styleDef.substring(FlListWidget.STYLE_COLUMN_SEPARATOR.length);

          columnSeparator = [];
          List<String> separators = styleDef.split("_");

          for (int i = 0; i < separators.length; i++) {
            columnSeparator.add(separators[i].
              replaceAll("%20", " ").
              replaceAll("%5f", "_").
              replaceAll("%5F", "_").
              replaceAll("%2c", ",").
              replaceAll("%2C", ","));
          }
        }
        else if (!withArrow && styleDef == FlListWidget.STYLE_WITH_ARROW) {
          withArrow = true;
        }
        else if (styleDef == FlListWidget.STYLE_VALIGN_TOP) {
          vAlign = MainAxisAlignment.start;
        }
        else if (styleDef == FlListWidget.STYLE_VALIGN_BOTTOM) {
          vAlign = MainAxisAlignment.end;
        }
      }
    }

    _closeSlidablesImmediate();
    _slideController.clear();

//    mapColumnsPerRow?.clear();
//    asCard = false;
//    withArrow = false;
//    vAlign = MainAxisAlignment.start;
    vAlign = null;

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
                    separatorBuilder: (context, index) {
                        if (asCard) {
                            return const Divider(height: 4, color: Colors.transparent);
                        }
                        else {
                            return Divider(height: 1.0, color: JVxColors.isLightTheme(context) ?  Colors.grey.shade300 : Colors.white70);
                        }
                    },
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

                      bool selected = index == widget.selectedRowIndex;

                      Widget listEntry = FlListEntry(
                          model: widget.model,
                          index: index,
                          columnDefinitions: widget.chunkData.columnDefinitions,
                          cellEditors: widget.cellEditors,
                          isSelected: selected,
                          values: widget.chunkData.data[index]!,
                          recordFormat: widget.chunkData.recordFormats?[widget.model.name],
                          template: tpl,
                          columnsPerRow: mapColumnsPerRow,
                          columnSeparator: columnSeparator,
                          mainAxisAlignment: vAlign
                      );

                      if (withArrow) {
                        listEntry = Flex(direction: Axis.horizontal,
                          children: [
                            Flexible(
                              flex: 1,
                              fit: FlexFit.tight,
                              child: listEntry
                            ),
                            Flexible(
                              flex: 0,
                              fit: FlexFit.loose,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: Icon(Icons.arrow_forward_ios,
                                color: Colors.grey.shade300)
                              )
                            )
                          ],
                        );
                      }

                      if (selected && widget.model.showSelection) {
                        ApplicationSettingsResponse applicationSettings = AppStyle.of(context).applicationSettings;

                        Color? colSelection;

                        if (JVxColors.isLightTheme(context)) {
                          colSelection = applicationSettings.colors?.activeSelectionBackground;
                        } else {
                          colSelection = applicationSettings.darkColors?.activeSelectionBackground;
                        }

                        colSelection ??= Theme.of(context).colorScheme.primary;

                        colSelection = colSelection.withAlpha(Color.getAlphaFromOpacity(0.10));

                        listEntry = Container(color: colSelection, child: listEntry);
                      }

                      if (widget.slideActionFactory != null) {
                        List<SlidableAction> slideActions = widget.slideActionFactory?.call(context, index) ?? [];

                        listEntry = Theme(
                          data: Theme.of(context).copyWith(
                            outlinedButtonTheme: OutlinedButtonThemeData(
                              style: OutlinedButton.styleFrom(
                                iconColor: slideActions.isNotEmpty ? slideActions.first.foregroundColor : Colors.white,
                                textStyle: const TextStyle(fontWeight: FontWeight.normal),
                                iconSize: 16))),
                          child: Slidable(
                            key: UniqueKey(),
                            controller: slideCtrl,
                            closeOnScroll: true,
                            direction: Axis.horizontal,
                            enabled: widget.slideActionFactory != null && slideActions.isNotEmpty == true && widget.model.isEnabled,
                            groupTag: widget.slideActionFactory,
                            endActionPane: ActionPane(
                              extentRatio: 0.50,
                              dismissible: DismissiblePane(
                                closeOnCancel: true,
                                onDismissed: () {
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

                                  slideActions.last.onPressed!(context);
                                },
                              ),
                              motion: const StretchMotion(),
                              children: slideActions,
                            ),
                            child: listEntry
                          )
                        );
                      }

                      if (asCard) {
                        listEntry = Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(JVxColors.BORDER_RADIUS),
                            ),
                            color: Colors.white,
                            margin: const EdgeInsets.all(2),
                            child: ClipPath(
                                clipper: ShapeBorderClipper(shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(JVxColors.BORDER_RADIUS))),
                                child: listEntry
                            )
                        );
                      }

                      Widget listTile = ListTile(
                        minTileHeight: 10,
                        contentPadding: const EdgeInsets.all(0),
                        horizontalTitleGap: 0,
                        minVerticalPadding: 0,
                        title: listEntry
                      );

                      if (widget.onTap != null) {
                        listTile = GestureDetector(
                          onTap: widget.onTap != null && widget.model.isEnabled
                            ? () => widget.onTap!(index)
                            : null,
                          child: listTile,
                        );
                      }

                      return listTile;
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