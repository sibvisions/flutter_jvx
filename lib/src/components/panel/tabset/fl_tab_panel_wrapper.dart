import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../util/constants/i_color.dart';
import '../../../../util/image/image_loader.dart';
import '../../../../util/logging/flutter_logger.dart';
import '../../../layout/tab_layout.dart';
import '../../../model/command/api/close_tab_command.dart';
import '../../../model/command/api/open_tab_command.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../model/component/label/fl_label_model.dart';
import '../../../model/component/panel/fl_tab_panel_model.dart';
import '../../../model/layout/alignments.dart';
import '../../base_wrapper/base_comp_wrapper_widget.dart';
import '../../base_wrapper/base_cont_wrapper_state.dart';
import '../../label/fl_label_widget.dart';
import 'fl_tab_controller.dart';
import 'fl_tab_header.dart';
import 'fl_tab_view.dart';

enum TabPlacements { WRAP, TOP, LEFT, BOTTOM, RIGHT }

class FlTabPanelWrapper extends BaseCompWrapperWidget<FlTabPanelModel> {
  FlTabPanelWrapper({Key? key, required String id}) : super(key: key, id: id);

  @override
  _FlTabPanelWrapperState createState() => _FlTabPanelWrapperState();
}

class _FlTabPanelWrapperState extends BaseContWrapperState<FlTabPanelModel> with TickerProviderStateMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The current tab controller.
  late FlTabController tabController;

  /// If the layout gets rebuild after the build.
  bool layoutAfterBuild = false;

  /// The last deleted tab. -1 if no tab was deleted. -2 if the last tab was deleted.
  int lastDeletedTab = -1;

  /// The list of tab headers.
  List<Widget> tabHeaderList = [];

  /// The list of tab views.
  List<BaseCompWrapperWidget> tabContentList = [];

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    super.initState();

    layoutData.layout = TabLayout(tabHeaderHeight: 0.0); //, selectedIndex: model.selectedIndex);
    layoutData.children = uiService.getChildrenModels(model.id).map((e) => e.id).toList();

    layoutAfterBuild = true;
    tabController = FlTabController(tabs: [], vsync: this, changedIndexTo: changedIndexTo);

    buildChildren(pSetStateOnChange: false);
  }

  @override
  receiveNewModel({required FlTabPanelModel newModel}) {
    layoutData.children = uiService.getChildrenModels(model.id).map((e) => e.id).toList();
    super.receiveNewModel(newModel: newModel);

    // Performance optimization.
    // If ever inplemented, need to add a callback to the layout service "cleaning" itself from the "dirty" status.
    // There must be a mechanic that if a child is updated, and I, as a parent, have already cleaned myself, to layout after a child calls.
    // There must also be a mechanic that if a child is updated and I, as a parent, don't need relayouting, to still update because my Child has been updated.
    // if (newModel.lastChangedProperties.isNotEmpty) {
    //   if (newModel.lastChangedProperties.any((element) => LAYOUT_RELEVANT_PROPERTIES.contains(element))) {
    layoutAfterBuild = true;
    //   } else if (newModel.lastChangedProperties.contains(ApiObjectProperty.selectedIndex) &&
    //       tabController.widgetsSelectedOnce.contains(newModel.selectedIndex)) {
    //     layoutAfterBuild = true;
    //   }
    // }

    if (!buildChildren()) {
      setState(() {});
    }
  }

  @override
  affected() {
    layoutAfterBuild = true;

    if (!buildChildren()) {
      setState(() {});
    }
  }

  @override
  bool buildChildren({bool pSetStateOnChange = true}) {
    bool returnValue = super.buildChildren(pSetStateOnChange: false);

    tabHeaderList.clear();
    tabContentList.clear();

    if (lastDeletedTab >= 0) {
      tabController.widgetsSelectedOnce.remove(lastDeletedTab);

      if (tabController.widgetsSelectedOnce.isNotEmpty) {
        List<int> listOfSelectedIndex = tabController.widgetsSelectedOnce.toList();
        listOfSelectedIndex.sort();

        int i = lastDeletedTab + 1;
        while (i <= listOfSelectedIndex.last) {
          if (tabController.widgetsSelectedOnce.contains(i)) {
            tabController.widgetsSelectedOnce.remove(i);
            tabController.widgetsSelectedOnce.add(i - 1);
          }

          i++;
        }
      }
      lastDeletedTab = -2;
    }

    /// Sort children by index;
    for (Widget child in children.values) {
      if (child is BaseCompWrapperWidget) {
        tabContentList.add(child);
      }
    }

    tabContentList.sort((a, b) => a.model.indexOf - b.model.indexOf);

    tabController = FlTabController(
        initialIndex: min(tabController.index, max(tabContentList.length - 1, 0)),
        tabs: tabContentList,
        vsync: this,
        changedIndexTo: changedIndexTo,
        lastController: tabController);

    for (int i = 0; i < tabContentList.length; i++) {
      tabHeaderList.add(createTab(tabContentList[i], i));
    }

    LOGGER.logD(pType: LOG_TYPE.UI, pMessage: "BUILD CHILDREN");
    LOGGER.logD(pType: LOG_TYPE.UI, pMessage: "Children count: ${children.values.length}");
    LOGGER.logD(pType: LOG_TYPE.UI, pMessage: "Tabcontentlist: $tabContentList");
    LOGGER.logD(pType: LOG_TYPE.UI, pMessage: "Tabheaderlist: $tabHeaderList");
    LOGGER.logD(pType: LOG_TYPE.UI, pMessage: "Model Selected index:${model.selectedIndex}");
    LOGGER.logD(
        pType: LOG_TYPE.UI,
        pMessage: "Tabcontroller: ${tabController.index} + Once selected: ${tabController.widgetsSelectedOnce}");
    LOGGER.logD(pType: LOG_TYPE.UI, pMessage: "Set state: $returnValue");

    if (returnValue && pSetStateOnChange) {
      setState(() {});
    }

    return returnValue;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> childrenToHide = tabContentList.where((e) {
      return !tabController.widgetsSelectedOnce.contains(tabContentList.indexOf(e));
    }).toList();
    LOGGER.logD(pType: LOG_TYPE.UI, pMessage: "ChildrenToHide: $childrenToHide");

    return getPositioned(
      child: Wrap(
        direction: Axis.vertical,
        verticalDirection: TabPlacements.BOTTOM == model.tabPlacement ? VerticalDirection.up : VerticalDirection.down,
        children: [
          SizedBox(
            width: widthOfTabPanel,
            height: (layoutData.layout as TabLayout).tabHeaderHeight,
            child: FlTabHeader(
              tabHeaderList: tabHeaderList,
              postFrameCallback: postFrameCallback,
              tabController: tabController,
            ),
          ),
          SizedBox(
            width: widthOfTabPanel,
            height: heightOfTabPanel,
            child: GestureDetector(
              onScaleEnd: swipe,
              child: TabBarView(
                controller: tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: tabContentList
                    .map(
                      (e) => Visibility(
                        child: Stack(
                          children: [FlTabView(child: e)],
                        ),
                        maintainAnimation: true,
                        maintainInteractivity: true,
                        maintainSemantics: true,
                        maintainState: true,
                        visible: tabController.isTabEnabled(e.model.indexOf),
                        maintainSize: true,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          SizedBox(
            width: 0,
            height: 0,
            child: childrenToHide.isNotEmpty
                ? Visibility(
                    child: Stack(
                      children: childrenToHide,
                    ),
                    maintainAnimation: true,
                    maintainInteractivity: false,
                    maintainSemantics: false,
                    maintainState: true,
                    visible: false,
                    maintainSize: true,
                  )
                : null,
          ),
        ],
      ),
    );
  }

  @override
  void postFrameCallback(BuildContext context) {
    if (lastDeletedTab == -2 && model.selectedIndex > 0) {
      tabController.animateTo(model.selectedIndex, pInternally: true);
    }
    lastDeletedTab = -1;

    if (model.selectedIndex >= 0 && tabController.index != model.selectedIndex) {
      tabController.animateTo(model.selectedIndex, pInternally: true);
    }

    TabLayout layout = (layoutData.layout as TabLayout);

    double tabHeaderHeight =
        (context.findRenderObject() as RenderBox).getMaxIntrinsicHeight(double.infinity).ceilToDouble();

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
    tabController.dispose();
    super.dispose();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void swipeLeft(bool pInternally) {
    _swipe(false, pInternally);
  }

  void swipeRigth(bool pInternally) {
    _swipe(true, pInternally);
  }

  void _swipe(bool pRight, bool pInternally) {
    int index = tabController.index;
    bool hasSwiped = false;
    while (!hasSwiped) {
      if (pRight) {
        index++;
      } else {
        index--;
      }

      if (index >= 0 && index < tabContentList.length) {
        if (tabController.isTabEnabled(index)) {
          tabController.animateTo(index, pInternally: pInternally);
          hasSwiped = true;
        }
      } else {
        hasSwiped = true;
      }
    }
  }

  void swipe(ScaleEndDetails pDetails) {
    if (pDetails.velocity.pixelsPerSecond.dx.abs() == 0.0 ||
        pDetails.velocity.pixelsPerSecond.dx.abs() < pDetails.velocity.pixelsPerSecond.dy.abs()) {
      return;
    }

    // Bigger than 0 -> Swipe to the left;
    // Negative number -> swipe to the right;
    _swipe(pDetails.velocity.pixelsPerSecond.dx < 0.0, false);
  }

  void changedIndexTo(int pValue) {
    // setState(() {
    //   model.selectedIndex = pValue;
    // });

    uiService.sendCommand(OpenTabCommand(componentName: model.name, index: pValue, reason: "Opened the tab."));
  }

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

  Widget createTab(BaseCompWrapperWidget pComponent, int pIndex) {
    FlComponentModel childModel = pComponent.model;
    String pTabString = childModel.constraints!;

    List pTabStrings = pTabString.split(';');
    bool enabled = (pTabStrings[0]?.toLowerCase() == 'true');
    bool closable = (pTabStrings[1]?.toLowerCase() == 'true');
    String text = pTabStrings[2] ?? '';
    String imageString = pTabStrings.length >= 4 ? pTabStrings[3] : '';

    Widget? image;
    if (imageString.isNotEmpty) {
      image = ImageLoader.loadImage(imageString,
          pWantedSize: const Size(16, 16), pWantedColor: enabled ? null : IColorConstants.COMPONENT_DISABLED);
    }

    FlLabelModel labelModel = FlLabelModel()
      ..text = text
      ..fontName = childModel.fontName
      ..fontSize = childModel.fontSize
      ..foreground = childModel.foreground
      ..isBold = childModel.isBold
      ..isItalic = childModel.isItalic
      ..verticalAlignment = VerticalAlignment.CENTER
      ..isEnabled = enabled;

    Widget textChild = FlLabelWidget(model: labelModel);

    return Tab(
      child: closable
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                image ?? Container(),
                const SizedBox(width: 5),
                textChild,
                const SizedBox(width: 5),
                InkWell(
                  onTap: enabled
                      ? () {
                          closeTab(pIndex);
                        }
                      : null,
                  child: const Icon(
                    Icons.clear,
                    size: 18,
                    color: IColorConstants.COMPONENT_DISABLED,
                  ),
                ),
              ],
            )
          : textChild,
      //icon: image,
      iconMargin: const EdgeInsets.all(5),
    );
  }

  void closeTab(int index) {
    LOGGER.logI(pType: LOG_TYPE.UI, pMessage: "Closing tab $index");
    lastDeletedTab = index;
    uiService.sendCommand(CloseTabCommand(componentName: model.name, index: index, reason: "Closed tab"));
  }
}

// Old possible build for non animated tab
// return getPositioned(
//   child: Wrap(
//     children: [
//       FlTabHeader(tabHeaderList: tabHeaderList, postFrameCallback: postFrameCallback),
//       GestureDetector(
//         onHorizontalDragEnd: swipe,
//         child: Stack(
//           children: [
//             SizedBox(
//               width: widthOfTabPanel,
//               height: heightOfTabPanel,
//             ),
//             ...tabContentList.map(
//               (e) => Positioned(
//                 top: 0,
//                 left: 0,
//                 width: widthOfTabPanel,
//                 height: heightOfTabPanel,
//                 child: Visibility(
//                   child: Stack(
//                     children: [e],
//                   ),
//                   maintainAnimation: true,
//                   maintainInteractivity: false,
//                   maintainSemantics: false,
//                   maintainState: true,
//                   visible: e.model.indexOf == model.selectedIndex,
//                   maintainSize: true,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     ],
//   ),
// );