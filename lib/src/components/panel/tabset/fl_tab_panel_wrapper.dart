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

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../flutter_ui.dart';
import '../../../layout/tab_layout.dart';
import '../../../model/command/api/close_tab_command.dart';
import '../../../model/command/api/select_tab_command.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../model/layout/alignments.dart';
import '../../../service/command/i_command_service.dart';
import '../../../service/storage/i_storage_service.dart';
import '../../../util/image/image_loader.dart';
import '../../../util/jvx_colors.dart';
import '../../../util/parse_util.dart';
import '../../base_wrapper/base_comp_wrapper_state.dart';
import '../../base_wrapper/base_comp_wrapper_widget.dart';
import '../../base_wrapper/base_cont_wrapper_state.dart';
import '../../components_factory.dart';
import '../../editor/text_field/fl_text_field_widget.dart';
import '../../label/fl_label_widget.dart';
import 'fl_tab_controller.dart';

enum TabPlacements { WRAP, TOP, LEFT, BOTTOM, RIGHT }

typedef _LayoutConstraints = ({
  bool enabled,
  bool closable,
  String text,
  String imageString,
  bool imageWithSize,
  double? imageWidth,
  double? imageHeight
});

class FlTabPanelWrapper extends BaseCompWrapperWidget<FlTabPanelModel> {
  const FlTabPanelWrapper({super.key, required super.model, super.offstage});

  @override
  BaseCompWrapperState<FlComponentModel> createState() => _FlTabPanelWrapperState();
}

class _FlTabPanelWrapperState extends BaseContWrapperState<FlTabPanelModel> with TickerProviderStateMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  //48 = 46 + indicatorWeight (see tabs.dart - _kTabHeight)
  static double maxTabHeight = 48;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// the header key
  final GlobalKey _keyHeader = GlobalKey(debugLabel: "headerKey");

  /// The current tab controller.
  /// The current tab controller.
  late FlTabController _tabController;
  late PageController _pageController;

  /// If the layout gets rebuild after the build.
  bool layoutAfterBuild = false;

  /// contains tabs which should be removed asap.
  Set<int> tabsToBeRemoved = {};

  /// The list of tab headers.
  List<Widget> tabHeaderList = [];

  /// The list of tab views.
  List<Widget> tabContentList = [];

  /// The list of (offstage) tab view components.
  List<Widget> tabContentListOffstage = [];

  /// The list of tab view components.
  List<BaseCompWrapperWidget> tabContentComponents = [];

  /// The list of indices of enabled tab contents.
  List<int> enabledTabContentIndices = [];

  /// all available children
  Map<Key, KeepAliveWrapper> allComponents = {};

  /// all available (offstage) layout components
  Map<String, Widget> allOffstageComponents = {};

  /// last sent selected tab index
  int _lastSentIndex = -1;

  /// max tab-height
  double _maxTabHeight = -1;

  /// whether first initialization is done
  bool initDone = false;

  /// whether tab is scrollable
  bool _isScrollable = true;

  /// whether changing index by manual tap
  bool _isManualTap = false;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  _FlTabPanelWrapperState() : super();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    super.initState();

    _tabController = FlTabController(vsync: this);
    _pageController = PageController();

    _pageController.addListener(() {
      //avoid problems with animation
      if (_tabController.indexIsChanging) {
        return;
      }

      if (!_pageController.hasClients || _pageController.page == null) {
          return;
      }

      double page = _pageController.page!;

      //check that index is in range (e.g. removed tab)
      if (page >= enabledTabContentIndices.length - 1) {
        page = (enabledTabContentIndices.length - 1).toDouble();
      }

      int floor = page.floor();
      int ceil = page.ceil();
      double fraction = page - floor;

      // Mapping mit Range-Check
      int startTab = enabledTabContentIndices[floor];
      int endTab = enabledTabContentIndices[ceil];

      //calculate target position in header (e.g. 0.0 -> 3.0)
      double mappedHeaderPos = startTab + (fraction * (endTab - startTab));

      int closestTabIndex = mappedHeaderPos.round();

      //change only if necessary
      if (_tabController.index != closestTabIndex) {
        _tabController.index = closestTabIndex;
      }

      _tabController.offset = (mappedHeaderPos - closestTabIndex).clamp(-1.0, 1.0);
    });

    layoutData.layout = TabLayout();

    layoutAfterBuild = true;

    buildChildren(setStateOnChange: false);
  }

  @override
  void modelUpdated() {
    super.modelUpdated();

    layoutAfterBuild = true;

    buildChildren(forceSetState: true);
  }

  @override
  void reassemble() {
    super.reassemble();

    tabHeaderList.clear();
    (layoutData.layout as TabLayout).tabHeaderHeight = 0;
  }

  @override
  void affected() {
    layoutAfterBuild = true;

    buildChildren(forceSetState: true);
  }

  @override
  bool buildChildren({bool setStateOnChange = true, bool forceSetState = false}) {
    bool childrenChanged = super.buildChildren(setStateOnChange: false);

    if (childrenChanged) {
      _isScrollable = true;

      tabHeaderList.clear();
      tabContentList.clear();

      enabledTabContentIndices.clear();
      tabContentComponents.clear();
      tabContentListOffstage.clear();

      tabsToBeRemoved.clear();

      KeepAliveWrapper? aliveWrapper;

      FlComponentModel compModel;
      Widget? wOffstage;

      IStorageService servStorage = IStorageService();

      //cleanup removed components
      allComponents.removeWhere((key, value) => servStorage.getComponentModel(pComponentId: value.modelId) == null);
      allOffstageComponents.removeWhere((key, value) => servStorage.getComponentModel(pComponentId: key) == null);


      for (int i = 0; i < childWidgets.length; i++) {
        tabContentComponents.add((childWidgets[i] as BaseCompWrapperWidget));

        compModel = tabContentComponents[i].model;

        wOffstage = allOffstageComponents[compModel.id];

        if (wOffstage == null) {
          // we need a copy of the component as placeholder for layout events
          // but we can't use the original widget because of the global key
          // so we create a new widget but don't render anything
          wOffstage = ComponentsFactory.buildWidget(
            compModel,
            keyProvider: (id) => ValueKey("copy $id"),
            offstage: true
          );

          allOffstageComponents[compModel.id] = wOffstage;
        }

        tabContentListOffstage.add(wOffstage);

        aliveWrapper = allComponents[childWidgets[i].key!];

        if (aliveWrapper == null) {
          aliveWrapper = KeepAliveWrapper(
              modelId: compModel.id,
              key: ValueKey("content: ${compModel.id}"),
              child: childWidgets[i]);

          allComponents[childWidgets[i].key!] = aliveWrapper;
        }

        tabContentList.add(aliveWrapper);
      }

      int cnt = tabContentComponents.length;

      //sort by indexOf
      for (int i = 0; i < cnt - 1; i++) {
        for (int j = 0; j < cnt - i - 1; j++) {
          if (tabContentComponents[j].model.indexOf > tabContentComponents[j + 1].model.indexOf) {
            var tempComp = tabContentComponents[j];
            tabContentComponents[j] = tabContentComponents[j + 1];
            tabContentComponents[j + 1] = tempComp;

            var tempList = tabContentList[j];
            tabContentList[j] = tabContentList[j + 1];
            tabContentList[j + 1] = tempList;
          }
        }
      }

      List<bool> enabledState = List.filled(childWidgets.length, true);

      for (int i = 0; i < tabContentComponents.length; i++) {
        enabledState[i] = ParseUtil.parseBoolOrTrue(tabContentComponents[i].model.constraints
            ?.split(";")
            .first);

        if (enabledState[i]) {
          enabledTabContentIndices.add(i);
        }
      }

      FlTabController oldController = _tabController;

      try {
        int index = min(_tabController.index, max(tabContentList.length - 1, 0));

        _tabController = FlTabController(
          length: tabContentList.length,
          initialIndex: index,
          vsync: this,
          enabledState: enabledState,
        );

        if (!enabledState[index]) {
          _tabController.animateTo(model.selectedIndex);
        }

        if (_pageController.hasClients) {
          if (enabledTabContentIndices.isNotEmpty) {
            _pageController.jumpToPage(enabledTabContentIndices.indexOf(index));
          }
        }
      }
      finally {
        Future.delayed(kTabScrollDuration, () => oldController.dispose());
      }

      if (forceSetState || (childrenChanged && setStateOnChange)) {
        setState(() {});
      }
    }
    else {
      if (model.selectedIndex >= 0 && _tabController.index != model.selectedIndex) {
        _pageController.animateToPage(enabledTabContentIndices.indexOf(model.selectedIndex), duration: kTabScrollDuration, curve: Curves.easeInOut);
      }

      if (forceSetState) {
        setState(() {});
      }
    }

    return childrenChanged;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.offstage) {
      return wrapWidget(context, Offstage());
    }

    if (tabHeaderList.isEmpty) {
      List<_LayoutConstraints> constraints = [];

      //pre-parse constraints
      for (int i = 0; i < tabContentList.length; i++) {
        constraints.add(_parseConstraints(tabContentComponents[i].model.constraints));
      }

      if (model.isTabHeaderScroll) {
        _isScrollable = true;
      }
      else {
        int withText = 0;
        int withImage = 0;
        int withClose = 0;

        //analyze constraints for tab header configuration
        for (int i = 0; i < constraints.length; i++) {
          if (constraints[i].closable) {
            withClose++;
          }
          if (constraints[i].text.isNotEmpty) {
            withText++;
          }
          if (constraints[i].imageString.isNotEmpty) {
            withImage++;
          }
        }

        if (withText == 0 && withImage == constraints.length) {
          //only images -> an indicator for disabled scrolling
          _isScrollable = constraints.length > 6;
        }
        else if (withClose == 0) {
          //text and images but not closable
          _isScrollable = constraints.length > 4;
        }
      }

      _maxTabHeight = maxTabHeight;

      Tab tab;
      for (int i = 0; i < tabContentList.length; i++) {
        tab = _createTab(context, tabContentComponents[i], i, scrollable: _isScrollable, constraints: constraints[i]);
        _maxTabHeight = max(_maxTabHeight, tab.height ?? 0);

        tabHeaderList.add(tab);
      }
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    ColorScheme colorScheme = Theme.of(context).colorScheme;

    TabBar tabBar = TabBar(
      key: _keyHeader,
      dividerHeight: 0,
      indicator: TabPlacements.BOTTOM == model.tabPlacement ? _getBottomIndicator(_maxTabHeight) : null,
      labelColor: colorScheme.onSurface,
      //indicatorColor: colorScheme.onSurface,
      controller: _tabController,
      tabs: tabHeaderList,
      isScrollable: _isScrollable,
      tabAlignment: _isScrollable ? TabAlignment.start : null,
      onTap: (value) async {
        _isManualTap = true;

        try {
          if (!_tabController.isTabEnabled(value)) {
            return;
          }

          int contentPos = enabledTabContentIndices.indexOf(value);

          _tabController.animateTo(contentPos);

          int currentPage = _pageController.page!.round();

          if ((contentPos - currentPage).abs() > 1) {
            int neighborIndex = contentPos > currentPage ? contentPos - 1 : contentPos + 1;
            _pageController.jumpToPage(neighborIndex);

            await WidgetsBinding.instance.endOfFrame;
          }

          unawaited(_pageController.animateToPage(contentPos, duration: kTabScrollDuration, curve: Curves.easeInOut));

          if (_lastSentIndex != value) {
            unawaited(ICommandService().sendCommand(
              SelectTabCommand(componentName: model.name, index: value, reason: "Selects the tab."),
            ));

            _lastSentIndex = value;
          }
        }
        finally {
          _isManualTap = false;
        }
      },
    );

    Widget header;

    if (model.background != null) {
      header = Container(
        width: widthOfTabPanel,
        height: (layoutData.layout as TabLayout).tabHeaderHeight,
        decoration: BoxDecoration(
          borderRadius: model.isTabHeaderRounded ? BorderRadius.circular(4.0) : null,
          color: model.background,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          child: tabBar,
        ),
      );
    }
    else {
      header = SizedBox(
        width: widthOfTabPanel,
        height: (layoutData.layout as TabLayout).tabHeaderHeight,
        child: tabBar
      );
    }

    return wrapWidget(
      context,
      Wrap(
        direction: Axis.vertical,
        verticalDirection: TabPlacements.BOTTOM == model.tabPlacement ? VerticalDirection.up : VerticalDirection.down,
        children: [
          header,
          if (heightOfTabPanel > 0)
            //we don't set the background color for content area, because background color
            //of panels is only set manually and is transparent. So we use SizedBox instead
            //of Container
          SizedBox(
            width: widthOfTabPanel,
            height: heightOfTabPanel,
            child: //NotificationListener<ScrollEndNotification>(
//              onNotification: (notification) {
//                int finalPageIndex = _pageController.page!.round();
//                _tabController.index = enabledContentIndices[finalPageIndex];
//                _tabController.offset = 0.0;
//                return true;
//              },
//              child:
            PageView.builder(
                controller: _pageController,
                itemCount: enabledTabContentIndices.length,
                findChildIndexCallback: (Key key) {
                  for (int i = 0; i < tabContentList.length; i++) {
                    if (tabContentList[i].key == key) {
                      return i;
                    }
                  }

                  return -1;
                },
                onPageChanged: (index) {
                  int originalIndex = enabledTabContentIndices[index];

                  if (!_isManualTap) {
                    _tabController.animateTo(originalIndex);

                    if (_lastSentIndex != originalIndex) {
                      ICommandService().sendCommand(
                        SelectTabCommand(componentName: model.name, index: originalIndex, reason: "Selects the tab."),
                      );

                      _lastSentIndex = originalIndex;
                    }
                  }
                },
                itemBuilder: (context, index) {
                  Widget wrapper = tabContentList[enabledTabContentIndices[index]];

                  return Stack(children: [wrapper]);
                },
              )
          ),
          SizedBox(
            width: 0,
            height: 0,
            child: Stack(
              children: heightOfTabPanel == 0 ? tabContentComponents : tabContentListOffstage
            )
          )
        ],
      ),
    );
  }

  @override
  void postFrameCallback(BuildContext context) {
    if (_tabController.index == 0 && _tabController.offset == 0.0 && !initDone) {
      //otherwise, first tab is centered and not fully visible -> because of TabAlignment.start
      _tabController.offset = 0.0001;
      _tabController.offset = 0.0;
    }

    TabLayout layout = (layoutData.layout as TabLayout);

    double tabHeaderHeight =_keyHeader.currentContext == null ? 0 :
    (_keyHeader.currentContext!.findRenderObject() as RenderBox).getMaxIntrinsicHeight(double.infinity).ceilToDouble();

    if (tabHeaderHeight != layout.tabHeaderHeight) {
      layout.tabHeaderHeight = tabHeaderHeight;
      layoutAfterBuild = true;
    }

    if (layoutAfterBuild) {
      registerParent();

      layoutAfterBuild = false;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();

    super.dispose();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  double get widthOfTabPanel {
    if (layoutData.hasPosition) {
      return layoutData.layoutPosition!.width;
    }

    return 0.0;
  }

  double get heightOfTabPanel {
    if (layoutData.hasPosition) {
      return layoutData.layoutPosition!.height - (layoutData.layout as TabLayout).tabHeaderHeight;
    }

    return 0.0;
  }

  _LayoutConstraints _parseConstraints(String? constraintString) {
    final constraints = constraintString?.split(";") ?? [];

    double? width;
    double? height;

    if (constraints.length > 3) {
      List<String> split = constraints[3].split(",");

      if (split.length >= 3) {
        width = double.tryParse(split[1]);
        height = double.tryParse(split[2]);
      }
    }

    return (
      enabled: constraints.isNotEmpty ? ParseUtil.parseBoolOrTrue(constraints[0]) : true,
      closable: constraints.length > 1 ? ParseUtil.parseBoolOrFalse(constraints[1]) : false,
      text: constraints.length > 2 ? constraints[2] : "",
      imageString: constraints.length > 3 ? constraints[3] : "",
      imageWithSize: width != null || height != null,
      imageWidth: width,
      imageHeight: height
    );
  }

  Decoration _getBottomIndicator(double height) {
    final ThemeData theme = Theme.of(context);
    final TabBarThemeData tabBarTheme = TabBarTheme.of(context);

    Color color = tabBarTheme.indicatorColor ?? theme.colorScheme.primary;

    if (color.toARGB32() == Material.maybeOf(context)?.color?.toARGB32()) {
      color = Colors.white;
    }

    final BorderRadius? effectiveBorderRadius = theme.useMaterial3
      ? BorderRadius.only(
          bottomLeft: Radius.circular(3),
          bottomRight: Radius.circular(3),
        )
      : null;

    return UnderlineTabIndicator(
      borderRadius: effectiveBorderRadius,
      borderSide: BorderSide(
        width: 3,
        color: color,
      ),
      //-1 because custom calculated height is without indicator
      insets: EdgeInsets.only(bottom: height > maxTabHeight ? height - 1 : height - 3),
    );
  }

  Tab _createTab(BuildContext context, BaseCompWrapperWidget pComponent, int pIndex, {bool scrollable = true, _LayoutConstraints? constraints}) {
    FlComponentModel childModel = pComponent.model;

    constraints ??= _parseConstraints(childModel.constraints);

    Widget? image;

    if (constraints.imageString.isNotEmpty) {
      image = ImageLoader.loadImage(
        constraints.imageString,
        //image definition contains size info!
        width: !scrollable && constraints.imageWithSize ? null : 16,
        height: !scrollable && constraints.imageWithSize ? null : 16,
        color: constraints.enabled ? null : (JVxColors.isLightTheme(context) ? JVxColors.COMPONENT_DISABLED : JVxColors.COMPONENT_DISABLED_LIGHTER)
      );
    }

    Widget? textChild;

    FlLabelModel? labelModel;

    if (constraints.text.isNotEmpty) {
      labelModel = FlLabelModel()
        ..text = constraints.text
        ..font = childModel.font ?? model.font
        ..foreground = childModel.foreground ?? model.foreground
        ..verticalAlignment = VerticalAlignment.CENTER
        ..isEnabled = constraints.enabled;

      textChild = FlLabelWidget.createTextWidget(labelModel, overflow: TextOverflow.fade, softwrap: false);
    }

    double? height;

    if (!scrollable) {
      height = maxTabHeight;

      double heightNew = 0;

      if (constraints.imageWithSize) {
        heightNew += constraints.imageHeight ?? 16;
      }
      else if (image != null) {
        heightNew += 16;
      }
      if (labelModel != null) {
        heightNew += ParseUtil.getTextHeight(text: "a", style: labelModel.createTextStyle());
      }

      height = max(maxTabHeight, heightNew + 8);
    }

    List<Widget> imageText = [];

    if (model.isTabAlignmentVertical) {
      imageText.add(Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (image != null) image,
          if (image != null && textChild != null) const SizedBox(height: 5),
          if (textChild != null && !scrollable) Flexible(child: textChild),
          if (textChild != null && scrollable) textChild
        ]
      ));

      if (height != null) {
        height += 5;
      }
    }
    else {
      if (!scrollable) {

        if (image != null) {
          imageText.add(image);
        };

        if (image != null && textChild != null) {
          imageText.add(const SizedBox(width: 5));
        }

        if (textChild != null) {
          imageText.add(Flexible(child: textChild));
        }
      }
      else {
        if (image != null) {
          imageText.add(image);
        }

        if (image != null && textChild != null) {
          imageText.add(const SizedBox(width: 5));
        }

        if (textChild != null) {
          imageText.add(textChild);
        }
      }
    }

    if (imageText.isEmpty) {
      imageText.add(ImageLoader.DEFAULT_IMAGE);
    }

    return Tab(
      height: height,
      iconMargin: const EdgeInsets.all(0),
      child: constraints.closable || image != null
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 8),
              ...imageText,
              if (constraints.closable)
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: constraints.enabled
                      ? () => closeTab(pIndex)
                      : null,
                  child: Padding(
                    padding: EdgeInsets.only(left: 10, top: 8, bottom: 8, right: 4),
                    child: Icon(
                      Icons.clear,
                      size: FlTextFieldWidget.iconSize,
                      color: JVxColors.isLightTheme(context) ? JVxColors.COMPONENT_DISABLED : JVxColors.COMPONENT_DISABLED_LIGHTER
                    ),
                  ),
                ),
              if (!constraints.closable) const SizedBox(width: 8),
            ],
          )
        : textChild ?? ImageLoader.DEFAULT_IMAGE,
    );
  }

  void closeTab(int index) {
    FlutterUI.logUI.i("Closing tab $index");

    tabsToBeRemoved.add(index);

    ICommandService().sendCommand(CloseTabCommand(componentName: model.name, index: index, reason: "Closed tab"));
  }
}

class KeepAliveWrapper extends StatefulWidget {
  final String modelId;
  final Widget child;
  final bool keepAlive;

  const KeepAliveWrapper({required this.modelId, super.key, this.keepAlive = true, required this.child});

  @override
  State<KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => widget.keepAlive;

  @override
  void didUpdateWidget(KeepAliveWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.keepAlive != widget.keepAlive) {
      updateKeepAlive();
    }
  }

  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
