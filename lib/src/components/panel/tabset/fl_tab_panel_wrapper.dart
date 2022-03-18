import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../util/constants/i_color.dart';
import '../../../../util/font_awesome_util.dart';
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
  FlTabController? lastController;

  late FlTabController tabController;

  bool layoutAfterBuild = false;

  int lastDeletedTab = -1;
  List<Widget> tabHeaderList = [];
  List<BaseCompWrapperWidget> tabContentList = [];

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
  void dispose() {
    tabController.dispose();
    super.dispose();
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
      lastDeletedTab = -1;
    }

    /// Sort children by index;
    for (Widget child in children.values) {
      if (child is BaseCompWrapperWidget) {
        tabContentList.add(child);
      }
    }

    tabContentList.sort((a, b) => a.model.indexOf - b.model.indexOf);
    var selectedIndex = tabContentList.indexWhere((element) => element.model.indexOf == model.selectedIndex);

    lastController = tabController;
    tabController = FlTabController(
        initialIndex: selectedIndex >= 0 ? selectedIndex : 0,
        tabs: tabContentList,
        vsync: this,
        changedIndexTo: changedIndexTo);
    tabController.widgetsSelectedOnce.addAll(lastController!.widgetsSelectedOnce);

    for (int i = 0; i < tabContentList.length; i++) {
      tabHeaderList.add(createTab(tabContentList[i]));
    }

    LOGGER.logD(pType: LOG_TYPE.UI, pMessage: "Build children");
    LOGGER.logD(pType: LOG_TYPE.UI, pMessage: "${children.values.length}");
    LOGGER.logD(pType: LOG_TYPE.UI, pMessage: "Tabcontentlist: $tabContentList");
    LOGGER.logD(pType: LOG_TYPE.UI, pMessage: "Tabheaderlist: $tabHeaderList");
    LOGGER.logD(pType: LOG_TYPE.UI, pMessage: "${model.selectedIndex}");
    LOGGER.logD(
        pType: LOG_TYPE.UI,
        pMessage: "${tabController.index} + ${tabController.length} + ${tabController.widgetsSelectedOnce}");

    if (returnValue && pSetStateOnChange) {
      setState(() {});
    }

    return returnValue;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> childrenToHide = tabContentList
        .where((e) =>
            !tabController.widgetsSelectedOnce.contains(e.model.indexOf) && model.selectedIndex != e.model.indexOf)
        .toList();

    LOGGER.logD(pType: LOG_TYPE.UI, pMessage: "BUILD");
    LOGGER.logD(pType: LOG_TYPE.UI, pMessage: "${children.values.length}");
    LOGGER.logD(pType: LOG_TYPE.UI, pMessage: "Tabcontentlist: $tabContentList");
    LOGGER.logD(pType: LOG_TYPE.UI, pMessage: "Tabheaderlist: $tabHeaderList");
    LOGGER.logD(pType: LOG_TYPE.UI, pMessage: "Childrentohide: $childrenToHide");
    LOGGER.logD(pType: LOG_TYPE.UI, pMessage: "${model.selectedIndex}");
    LOGGER.logD(
        pType: LOG_TYPE.UI,
        pMessage: "${tabController.index} + ${tabController.length} + ${tabController.widgetsSelectedOnce}");

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
              onHorizontalDragEnd: swipe,
              child: TabBarView(
                controller: tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: tabContentList
                    .map((e) => Stack(
                          children: [FlTabView(child: e)],
                        ))
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
                      children: childrenToHide
                          .map(
                            (e) => FlTabView(child: e),
                          )
                          .toList(),
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

  void swipeLeft() {
    swipe(DragEndDetails(velocity: const Velocity(pixelsPerSecond: Offset(1, 0)), primaryVelocity: 1));
  }

  void swipeRigth() {
    swipe(DragEndDetails(velocity: const Velocity(pixelsPerSecond: Offset(-1, 0)), primaryVelocity: -1));
  }

  void swipe(DragEndDetails pDetails) {
    if (pDetails.primaryVelocity == null || pDetails.primaryVelocity == 0.0) {
      return;
    }

    // Bigger than 0 -> Swipe to the left;
    // Negative number -> swipe to the right;
    bool swipeRight = pDetails.primaryVelocity! < 0.0;

    int tabIndex = tabContentList.indexWhere((element) => element.model.indexOf == model.selectedIndex);

    bool hasSwiped = false;
    while (!hasSwiped) {
      if (swipeRight) {
        tabIndex++;
      } else {
        tabIndex--;
      }

      if (tabIndex >= 0 && tabIndex < tabContentList.length) {
        if (tabContentList.elementAt(tabIndex).model.isEnabled) {
          tabController.animateTo(tabIndex);
          hasSwiped = true;
        }
      } else {
        hasSwiped = true;
      }
    }
  }

  void changedIndexTo(int pValue) {
    setState(() {
      model.selectedIndex = pValue;
    });
    uiService.sendCommand(OpenTabCommand(componentName: model.name, index: pValue, reason: "Opened the tab."));
  }

  @override
  void postFrameCallback(BuildContext context) {
    if (lastController != null) {
      lastController!.dispose();
      lastController = null;
    }

    var tabIndex = tabContentList.indexWhere((element) => element.model.indexOf == model.selectedIndex);
    if (tabIndex >= 0 && tabController.index != tabIndex) {
      tabController.animateTo(tabIndex);
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

  Widget createTab(BaseCompWrapperWidget pComponent) {
    FlComponentModel childModel = pComponent.model;
    String pTabString = childModel.constraints!;

    List pTabStrings = pTabString.split(';');
    bool enabled = (pTabStrings[0]?.toLowerCase() == 'true');
    bool closable = (pTabStrings[1]?.toLowerCase() == 'true');
    String text = pTabStrings[2] ?? '';
    String img = pTabStrings.length >= 4 ? pTabStrings[3] : '';
    img = img.split(",")[0];

    Widget? image;
    if (IFontAwesome.checkFontAwesome(img)) {
      IconData iconData = IFontAwesome.ICONS[img] ?? FontAwesomeIcons.questionCircle;

      image = FaIcon(
        iconData,
        size: 16,
        color: enabled ? Colors.black : IColorConstants.COMPONENT_DISABLED,
      );
    } else {
      // TODO image
      // image = jsonImage;
    }

    FlLabelModel labelModel = FlLabelModel()
      ..text = text
      ..fontName = childModel.fontName
      ..fontSize = childModel.fontSize
      ..foreground = childModel.foreground
      ..isBold = childModel.isBold
      ..isItalic = childModel.isItalic
      ..verticalAlignment = VerticalAlignment.BOTTOM
      ..isEnabled = enabled;

    Widget textChild = FlLabelWidget(model: labelModel);

    return Tab(
      child: closable
          ? Row(
              children: [
                textChild,
                const SizedBox(
                  width: 5,
                ),
                GestureDetector(
                  onTap: enabled
                      ? () {
                          closeTab(childModel.indexOf);
                        }
                      : null,
                  child: const Icon(
                    Icons.clear,
                    size: 30,
                    color: IColorConstants.COMPONENT_DISABLED,
                  ),
                ),
              ],
            )
          : textChild,
      icon: image,
      iconMargin: const EdgeInsets.all(5),
    );
  }

  void closeTab(int index) {
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