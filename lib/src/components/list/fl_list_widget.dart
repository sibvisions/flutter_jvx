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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rfw/formats.dart';
import 'package:rfw/rfw.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import '../../flutter_ui.dart';
import '../../mask/state/app_style.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/data/data_book.dart';
import '../../model/data/subscriptions/data_chunk.dart';
import '../../model/response/application_settings_response.dart';
import '../../util/haptic_util.dart';
import '../../util/icon_util.dart';
import '../../util/ui_template_manager.dart';
import '../../util/jvx_colors.dart';
import '../../util/jvx_logger.dart';
import '../base_wrapper/fl_stateful_widget.dart';
import '../editor/cell_editor/i_cell_editor.dart';
import '../util/scroll_mixin.dart';
import 'fl_list_entry.dart';
import 'localwidgets/list_cell.dart';
import 'localwidgets/list_image.dart';
import 'localwidgets/list_space.dart';

typedef ListTapCallback = void Function(int rowIndex);
typedef ListLongPressCallback = void Function(int rowIndex, Offset globalPosition);
typedef ListSlideActionFactory = List<SlidableAction> Function(BuildContext context, int row);
typedef ListScrollCallback = void Function(ScrollNotification scrollNotification);
typedef ListScrollEndCallback = bool Function();

class FlListWidget extends FlStatefulWidget<FlTableModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // remote widget libraries
  static const LibraryName _coreName = LibraryName(<String>["core", "widgets"]);
  static const LibraryName _materialName = LibraryName(<String>["material", "widgets"]);
  static const LibraryName _localName = LibraryName(<String>["local", "widgets"]);
  static const LibraryName mainName = LibraryName(<String>["main"]);

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

  /// With this style the list will have a standard border
  static const String STYLE_STANDARD_BORDER = FlPanelModel.STYLE_STANDARD_BORDER;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Callbacks
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Gets called when the list should refresh
  final Future<void> Function()? onRefresh;

  /// Gets called when the user scrolled to the edge of the list.
  final ListScrollEndCallback? onEndScroll;

  /// Gets called when the user scrolled the list.
  final ListScrollCallback? onScroll;

  /// Gets called when the user taps
  final ListTapCallback? onTap;

  /// Gets called when the user long press
  final ListLongPressCallback? onLongPress;

  /// The action the floating button calls.
  final VoidCallback? onFloatingPress;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The data of the table.
  final DataChunk chunkData;

  /// The meta data of the table.
  final DalMetaData? metaData;

  /// Which slide actions are to be allowed to the row.
  final ListSlideActionFactory? slideActionFactory;

  /// The cell editors
  final Map<String, ICellEditor> cellEditors;

  /// The entry builder
  final ListEntryBuilder? entryBuilder;

  /// The selected current row.
  final int selectedRowIndex;

  /// Whether an initial scroll to selected record should happen
  final bool initialScrollToSelected;

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
    this.initialScrollToSelected = true,
    this.entryBuilder,
    this.onRefresh,
    this.onScroll,
    this.onEndScroll,
    this.onTap,
    this.onLongPress,
    this.onFloatingPress
  });

  @override
  State<FlListWidget> createState() => _FlListWidgetState();
}

class _FlListWidgetState extends State<FlListWidget> with TickerProviderStateMixin,
                                                          ScrollMixin {
  // remote widgets
  final Runtime _runtime = Runtime();

  /// The current sliver context
  BuildContext? _sliverContext;

  /// The item scroll controller.
  late ScrollController? _scrollController;

  /// The controller for the view observer
  late final SliverObserverController _observerController;

  /// The cache for slide controllers
  final List<SlidableController> _slideController = [];

  /// The cache for all dynamic widget creation futures (per template)
  final Map<String, Future<dynamic>> uiTemplateFutures = {};

  /// The template resource (style definition)
  String? uiTemplateName;

  /// Whether we have a new "unchecked" template
  bool newUITemplate = false;

  /// Whether to show list entries as cards (style definition)
  bool asCard = false;

  /// Whether to show a "next" arrow (style definition)
  bool withArrow = false;

  /// Whether to show a border around the list (style definition)
  bool withBorder = false;

  /// The vertical alignment of entry content (style definition)
  MainAxisAlignment? vAlign;

  /// The columns per row (style definition)
  Map<int, int>? mapColumnsPerRow;

  /// The column separators (style definition)
  List<String>? columnSeparator;

  /// The current future for the ui template (style definition)
  Future<dynamic>? uiTemplateFuture;

  /// The currently selected row index
  int selectedRowIndex = -1;

  /// Whether the list should scroll to the selected row
  bool _scrollToSelected = true;

  /// initializes styling
  void _initStyle() {
    uiTemplateName = null;

    asCard = false;
    withArrow = false;
    withBorder = false;
    vAlign = null;

    mapColumnsPerRow = null;
    columnSeparator = null;

    uiTemplateFuture = null;

    Set<String> styles = widget.model.styles;

    if (styles.isNotEmpty) {
      String? styleDef;

      for (int i = 0; i < styles.length; i++) {
        styleDef = styles.elementAt(i);

        if (styleDef.startsWith(FlListWidget.STYLE_TEMPLATE_MARKER)) {
          styleDef = styleDef.substring(FlListWidget.STYLE_TEMPLATE_MARKER.length);

          newUITemplate = true;

          uiTemplateName = styleDef;
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
            mapColumnsPerRow![i] = int.parse(colCount[i]);
          }
        }
        else if (styleDef.startsWith(FlListWidget.STYLE_COLUMN_SEPARATOR)) {
          //e.g. :_,_%20,%20 (first separator = colon, second = comma, third = space colon space)
          styleDef = styleDef.substring(FlListWidget.STYLE_COLUMN_SEPARATOR.length);

          columnSeparator = [];
          List<String> separators = styleDef.split("_");

          for (int i = 0; i < separators.length; i++) {
            columnSeparator!.add(separators[i].
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
        else if (styleDef == FlListWidget.STYLE_STANDARD_BORDER) {
          withBorder = true;
        }
      }
    }

    //sort of caching for the future because it should be possible to change the template
    //and we avoid multiple loading of template by using same future
    //(otherwise initState would be a better place)
    if (uiTemplateName != null) {
      if (!uiTemplateFutures.containsKey(uiTemplateName)) {
        uiTemplateFuture = UITemplateManager.loadTemplate(uiTemplateName!);

        uiTemplateFutures[uiTemplateName!] = uiTemplateFuture!;
      }
      else {
        uiTemplateFuture = uiTemplateFutures[uiTemplateName];
      }
    }

    //no border if cards are used -> makes no sense
    if (asCard) {
      withBorder = false;
    }
  }

  @override
  void initState() {
    super.initState();

    _initUITemplateEngine();

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

    _initStyle();
  }

  @override
  void didUpdateWidget(FlListWidget oldWidget ) {
    super.didUpdateWidget(oldWidget);

    _scrollToSelected |= widget.initialScrollToSelected;

    if (_scrollToSelected) {
      selectedRowIndex = -1;
    }

    _initStyle();
  }

  @override
  void dispose() {
    super.dispose();

    _runtime.dispose();

    FlutterUI.disposeGlobalSubscription(this);

    _scrollController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _closeSlidablesImmediate();
    _slideController.clear();

    if (_sliverContext != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _scrollTo(widget.selectedRowIndex);
      });
    }

    if (uiTemplateName != null && !UITemplateManager.hasTemplate(uiTemplateName)) {
      return FutureBuilder(
          future: uiTemplateFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              if (FlutterUI.logUI.cl(Lvl.e)) {
                FlutterUI.logUI.e(snapshot.error);
              }
              return Center(child: Text(FlutterUI.translate("An error has occurred!")));
            } else if (snapshot.hasData) {

              if (newUITemplate) {
                _updateUITemplateEngine();
              }

              return _buildList(
                context,
                snapshot.data!,
                mapColumnsPerRow,
                columnSeparator,
                vAlign,
                asCard,
                withBorder,
                withArrow);
            } else {
              return const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator()
                ]
              );
            }
          }
      );
    }

    if (newUITemplate) {
      _updateUITemplateEngine();
    }

    return _buildList(
      context,
      UITemplateManager.getTemplateFromCache(uiTemplateName),
      mapColumnsPerRow,
      columnSeparator,
      vAlign,
      asCard,
      withBorder,
      withArrow);
  }

  WidgetLibrary _createLocalWidgets() {
    return LocalWidgetLibrary(<String, LocalWidgetBuilder>{
      "ListCell": (BuildContext context, DataSource source) {
        return ListCell(
          columnName: source.v<String>(["columnName"]),
          useFormat: source.v<bool>(["useFormat"]) ?? true,
          prefix: source.v<String>(["prefix"]),
          postfix : source.v<String>(["postfix"])
        );
      },
      "ListSpace": (BuildContext context, DataSource source) {
        return ListSpace(
          notEmptyColumnNames: ArgumentDecoders.list(source, ["notEmptyColumnNames"], ArgumentDecoders.string),
          text: source.v<String>(["text"]),
          width: source.v<double>(["width"]),
          height: source.v<double>(["height"])
        );
      },
      "ListImage": (BuildContext context, DataSource source) {
        return ListImage(
          columnName: source.v<String>(["columnName"]),
          icon: IconUtil.fromString(source.v<String>(["icon"])),
          radius: source.v<double>(["radius"]),
          iconColor: ArgumentDecoders.color(source, ["iconColor"]),
          iconBackgroundColor: ArgumentDecoders.color(source, ["iconBackgroundColor"]),
        );
      }
    });
  }

  void _initUITemplateEngine() {
    _runtime.clearLibraries();

    // Local widget library
    _runtime.update(FlListWidget._coreName, createCoreWidgets());
    _runtime.update(FlListWidget._materialName, createMaterialWidgets());
    _runtime.update(FlListWidget._localName, _createLocalWidgets());
  }

  /// Updates UI template engine
  void _updateUITemplateEngine() {
    newUITemplate = false;

    dynamic tpl = UITemplateManager.getTemplateFromCache(uiTemplateName);

    if (tpl is String) {
      _runtime.update(FlListWidget.mainName, parseLibraryFile(tpl));
    }
    else {
      _runtime.update(FlListWidget.mainName, decodeLibraryBlob(tpl));
    }
    // Remote widget library
  }

  Widget _buildList(
    BuildContext context,
    dynamic uiTemplate,
    Map<int, int>? mapColumnsPerRow,
    List<String>? columnSeparator,
    MainAxisAlignment? verticalAlign,
    bool asCard,
    bool withBorder,
    bool withArrow) {

    double cardBorderRadius = AppStyle.of(context).direct.listCardBorderRadius();

    Widget list = _wrapList(context, _wrapSlider(context,
      NotificationListener<ScrollNotification>(
          onNotification: (notification) => _onInternalEndScroll(notification),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) => _onInternalScroll(notification),
            child:
              SliverViewObserver(
                controller: _observerController,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: _scrollController,
                  slivers: [
                    SliverList.separated(
                      separatorBuilder: (context, index) {
                        if (widget.chunkData.getRecordStatusRaw(index)?.contains("DISMISSED") == true) {
                          return Container();
                        }

                        if (asCard) {
                              return const Divider(height: 4, color: Colors.transparent);
                          }
                          else {
                              return Divider(height: 1.0, color: JVxColors.isLightTheme(context) ?  Colors.grey.shade300 : Colors.white70);
                          }
                      },
                      itemCount: widget.chunkData.data.length,
                      itemBuilder: (context, index) {
                        if (_sliverContext != context) {
                          _sliverContext = context;

                          SchedulerBinding.instance.addPostFrameCallback((_) {
                            _scrollTo(widget.selectedRowIndex);
                          });
                        }

                        SlidableController? slideCtrl;

                        if (widget.slideActionFactory != null) {
                          slideCtrl = SlidableController(this);

                          if (index > _slideController.length - 1) {
                            _slideController.add(slideCtrl);
                          }
                          else {
                            _slideController[index] = slideCtrl;
                          }
                        }

                        if (widget.chunkData.getRecordStatusRaw(index)?.contains("DISMISSED") == true) {
                          return Container();
                        }

                        bool selected = index == widget.selectedRowIndex && widget.model.showSelection;

                        Widget listEntry = FlListEntry(
                          model: widget.model,
                          runtime: uiTemplate != null ? _runtime : null,
                          index: index,
                          columnDefinitions: widget.chunkData.columnDefinitions,
                          cellEditors: widget.cellEditors,
                          isSelected: selected,
                          values: widget.chunkData.data[index]!,
                          recordFormat: widget.chunkData.recordFormats?[widget.model.name],
                          columnsPerRow: mapColumnsPerRow,
                          columnSeparator: columnSeparator,
                          mainAxisAlignment: verticalAlign,
                          entryBuilder: widget.entryBuilder,
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
                                  padding: EdgeInsets.only(right: selected ? 2 : 5),
                                  child: Icon(Icons.arrow_forward_ios,
                                  color: Colors.grey.shade300)
                                )
                              )
                            ],
                          );
                        }
                        else {
                          //we need the padding to avoid jumps on selection
                          listEntry = Padding(
                            padding: EdgeInsets.only(right: selected ? 2 : 5),
                            child: listEntry
                          );
                        }

                        if (selected) {
                          ApplicationSettingsResponse applicationSettings = AppStyle.of(context).applicationSettings;

                          Color? colSelection;

                          if (JVxColors.isLightTheme(context)) {
                            colSelection = applicationSettings.colors?.activeSelectionBackground;
                          } else {
                            colSelection = applicationSettings.darkColors?.activeSelectionBackground;
                          }

                          colSelection ??= Theme.of(context).colorScheme.primary;

                          colSelection = colSelection.withAlpha(Color.getAlphaFromOpacity(0.7));

                          listEntry = Container(decoration: BoxDecoration(
                            border: Border(right: BorderSide(color: colSelection,width: 3)),
                          ), child: listEntry);
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
                                    String? status = widget.chunkData.getRecordStatusRaw(index);

                                    if (status != null && !status.contains("DISMISSED")) {
                                      if (_slideController.length > index) {
                                        SlidableController ctrl = _slideController.elementAt(index);
                                        ctrl.close(duration: const Duration(milliseconds: 0));

                                        _slideController.removeAt(index);
                                      }

                                      widget.chunkData.setStatusRaw(index, "DISMISSED");

                                      HapticUtil.medium();

                                      setState(() {});
                                    }

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
                                borderRadius: BorderRadius.circular(cardBorderRadius),
                              ),
                              color: Colors.white,
                              margin: const EdgeInsets.all(2),
                              child: ClipPath(
                                  clipper: ShapeBorderClipper(shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(cardBorderRadius))),
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

                        if (widget.onTap != null || widget.onLongPress != null) {
                          listTile = GestureDetector(
                            onTap: widget.onTap != null && widget.model.isEnabled? () {
                                widget.onTap!(index);

                                _closeSlidables();
                              }
                              : null,
                            onLongPressStart: widget.onLongPress != null && widget.model.isEnabled ? (details) {
                                widget.onLongPress!(index, details.globalPosition);

                                _closeSlidables();
                              }
                              :
                              null,
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
    ));

    if (withBorder) {
      list = _withBorder(context, list);
    }

    return list;
  }

  Widget _wrapList(BuildContext context, Widget list) {
    Widget listWidget = list;

    if (widget.onRefresh != null && widget.model.isEnabled) {
      listWidget = wrapWithScrollConfiguration(context, RefreshIndicator(
        onRefresh: widget.onRefresh!,
        child: listWidget,
        notificationPredicate: (notification) => notification.depth == 0,
      ));
    }

    if (widget.onFloatingPress != null) {
      listWidget = Stack(children: [listWidget, _createFloatingButton(context)]);
    }

    return listWidget;
  }

  Widget _wrapSlider(BuildContext context, Widget list) {
    if (widget.slideActionFactory != null) {
      return SlidableAutoCloseBehavior(
        closeWhenOpened: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPressStart: widget.onLongPress != null && widget.model.isEnabled ? (details) {
            widget.onLongPress?.call(-1, details.globalPosition);

              _closeSlidables();
            }
            : null,
          onTap: () => _closeSlidables(),
          child: list,
        ),
      );
    }

    return list;
  }

  Widget _withBorder(BuildContext context, Widget list) {
    double borderRadius = AppStyle.of(context).direct.listBorderRadius();


    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          width: JVxColors.BORDER_WIDTH_DEFAULT,
          color: JVxColors.COMPONENT_BORDER,
        ),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: ClipRRect(
        // The clip rect is there to stop the rendering of the children.
        // Otherwise the children would clip the border of the parent container.
        borderRadius: BorderRadius.circular(borderRadius - JVxColors.BORDER_WIDTH_DEFAULT),
        child: list,
      ),
    );
  }

  /// Closes all slidables immediately without delay
  void _closeSlidablesImmediate() {
    _closeSlidables(null, const Duration(milliseconds:  0));
  }

  /// Closes all slidables with given or default delay. If an [event] is given
  /// the position of the table widget shouldn't collide with event position.
  /// Only events outside the table widget will be recognized
  void _closeSlidables([PointerEvent? event, Duration? duration]) {
    if (!mounted || _slideController.isEmpty || !context.mounted) {
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

  /// Creates the floating button that floats above the table on the bottom right
  Positioned _createFloatingButton(BuildContext context) {
    return Positioned(
      right: 10,
      bottom: 10,
      child: FloatingActionButton(
        heroTag: null,
        backgroundColor: AppStyle.of(context).direct.listFloatingButtonBackground() ?? Theme.of(context).colorScheme.primary,
        onPressed: widget.onFloatingPress,
        child: FaIcon(
          FontAwesomeIcons.squarePlus,
          color: widget.model.foreground ?? AppStyle.of(context).direct.listFloatingButtonForeground() ?? Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
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

    //not enough records -> wait
    if (widget.chunkData.data.length < rowIndex) {
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

}