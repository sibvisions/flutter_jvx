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

import '../../../flutter_ui.dart';
import '../../../layout/tab_layout.dart';
import '../../../model/command/api/close_tab_command.dart';
import '../../../model/command/api/open_tab_command.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../model/layout/alignments.dart';
import '../../../service/command/i_command_service.dart';
import '../../../service/storage/i_storage_service.dart';
import '../../../util/image/image_loader.dart';
import '../../../util/jvx_colors.dart';
import '../../base_wrapper/base_comp_wrapper_state.dart';
import '../../base_wrapper/base_comp_wrapper_widget.dart';
import '../../base_wrapper/base_cont_wrapper_state.dart';
import '../../label/fl_label_widget.dart';
import 'fl_tab_controller.dart';
import 'fl_tab_header.dart';

enum TabPlacements { WRAP, TOP, LEFT, BOTTOM, RIGHT }

class FlTabPanelWrapper extends BaseCompWrapperWidget<FlTabPanelModel> {
  const FlTabPanelWrapper({super.key, required super.model});

  @override
  BaseCompWrapperState<FlComponentModel> createState() => _FlTabPanelWrapperState();
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

  _FlTabPanelWrapperState() : super();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    super.initState();

    layoutData.layout = TabLayout(tabHeaderHeight: 0.0); //, selectedIndex: model.selectedIndex);
    layoutData.children =
        IStorageService().getAllComponentsBelowById(pParentId: model.id, pRecursively: false).map((e) => e.id).toList();

    layoutAfterBuild = true;
    tabController = FlTabController(tabs: [], vsync: this, changedIndexTo: changedIndexTo);

    buildChildren(pSetStateOnChange: false);
  }

  @override
  modelUpdated() {
    layoutData.children =
        IStorageService().getAllComponentsBelowById(pParentId: model.id, pRecursively: false).map((e) => e.id).toList();
    super.modelUpdated();

    layoutAfterBuild = true;

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
      lastController: tabController,
    );

    for (int i = 0; i < tabContentList.length; i++) {
      tabHeaderList.add(createTab(tabContentList[i], i));
    }

    FlutterUI.logLayout.d("BUILD CHILDREN");
    FlutterUI.logLayout.d("Children count: ${children.values.length}");
    FlutterUI.logLayout.d("TabContent list: $tabContentList");
    FlutterUI.logLayout.d("TabHeader list: $tabHeaderList");
    FlutterUI.logLayout.d("Model Selected index:${model.selectedIndex}");
    FlutterUI.logLayout
        .d("Tab Controller: ${tabController.index} + Once selected: ${tabController.widgetsSelectedOnce}");
    FlutterUI.logLayout.d("Set state: $returnValue");

    if (returnValue && pSetStateOnChange) {
      setState(() {});
    }

    return returnValue;
  }

  @override
  Widget build(BuildContext context) {
    List<BaseCompWrapperWidget> childrenToHide = tabContentList.where((e) {
      return !tabController.widgetsSelectedOnce.contains(tabContentList.indexOf(e));
    }).toList();
    FlutterUI.logUI.d("ChildrenToHide: $childrenToHide");

    return wrapWidget(
      child: Wrap(
        direction: Axis.vertical,
        verticalDirection: TabPlacements.BOTTOM == model.tabPlacement ? VerticalDirection.up : VerticalDirection.down,
        children: [
          Container(
            color: model.background,
            width: widthOfTabPanel,
            height: (layoutData.layout as TabLayout).tabHeaderHeight,
            child: FlTabHeader(
              tabHeaderList: tabHeaderList,
              postFrameCallback: postFrameCallback,
              tabController: tabController,
            ),
          ),
          Container(
            color: model.background,
            width: widthOfTabPanel,
            height: heightOfTabPanel,
            child: GestureDetector(
              onScaleEnd: swipe,
              child: TabBarView(
                controller: tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: tabContentList.map(
                  (e) {
                    return Visibility(
                      visible: tabController.isTabEnabled(e.model.indexOf),
                      maintainAnimation: true,
                      maintainState: true,
                      maintainSize: true,
                      child: Stack(
                        children: [e],
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
          ),
          SizedBox(
            width: 0,
            height: 0,
            child: childrenToHide.isNotEmpty
                ? Visibility(
                    visible: false,
                    maintainAnimation: true,
                    maintainState: true,
                    maintainSize: true,
                    child: Stack(
                      children: childrenToHide,
                    ),
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
      tabController.animateTo(model.selectedIndex, animate: true);
    }
    lastDeletedTab = -1;

    if (model.selectedIndex >= 0 && tabController.index != model.selectedIndex) {
      tabController.animateTo(model.selectedIndex, animate: true);
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

  void _swipe(bool pRight) {
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
          tabController.animateTo(index);
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
    _swipe(pDetails.velocity.pixelsPerSecond.dx < 0.0);
  }

  void changedIndexTo(int pValue) {
    if (tabController.isAllowedToAnimate) {
      ICommandService().sendCommand(
        OpenTabCommand(componentName: model.name, index: pValue, reason: "Opened the tab."),
      );
    }
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

    List pTabStrings = pTabString.split(";");
    bool enabled = (pTabStrings[0]?.toLowerCase() == "true");
    bool closable = (pTabStrings[1]?.toLowerCase() == "true");
    String text = pTabStrings[2] ?? "";
    String imageString = pTabStrings.length >= 4 ? pTabStrings[3] : "";

    Widget? image;
    if (imageString.isNotEmpty) {
      image = ImageLoader.loadImage(
        imageString,
        width: 16,
        height: 16,
        color: enabled ? null : JVxColors.COMPONENT_DISABLED,
      );
    }

    FlLabelModel labelModel = FlLabelModel()
      ..text = text
      ..font = childModel.font
      ..foreground = childModel.foreground
      ..verticalAlignment = VerticalAlignment.CENTER
      ..isEnabled = enabled;

    Widget textChild = FlLabelWidget.getTextWidget(labelModel);

    return Tab(
      iconMargin: const EdgeInsets.all(5),
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
                    color: JVxColors.COMPONENT_DISABLED,
                  ),
                ),
              ],
            )
          : textChild,
    );
  }

  void closeTab(int index) {
    FlutterUI.logUI.i("Closing tab $index");
    lastDeletedTab = index;
    ICommandService().sendCommand(CloseTabCommand(componentName: model.name, index: index, reason: "Closed tab"));
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
