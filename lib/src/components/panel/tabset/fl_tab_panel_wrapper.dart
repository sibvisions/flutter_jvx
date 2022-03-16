import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../util/constants/i_color.dart';
import '../../../../util/font_awesome_util.dart';
import '../../../layout/tab_layout.dart';
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

class FlTabPanelWrapper extends BaseCompWrapperWidget<FlTabPanelModel> {
  const FlTabPanelWrapper({Key? key, required FlTabPanelModel model}) : super(key: key, model: model);

  @override
  _FlTabPanelWrapperState createState() => _FlTabPanelWrapperState();
}

class _FlTabPanelWrapperState extends BaseContWrapperState<FlTabPanelModel> with TickerProviderStateMixin {
  FlTabController? lastController;

  late FlTabController tabController;

  bool layoutAfterBuild = false;

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
    layoutData.layout = TabLayout(tabHeaderHeight: 0.0); //, selectedIndex: model.selectedIndex);
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

    /// Sort children by index;
    for (Widget child in children.values) {
      if (child is BaseCompWrapperWidget) {
        tabContentList.add(child);
      }
    }

    tabContentList.sort((a, b) => a.model.indexOf - b.model.indexOf);

    lastController = tabController;
    tabController = FlTabController(
        initialIndex: tabContentList.indexWhere((element) => element.model.indexOf == model.selectedIndex),
        tabs: tabContentList,
        vsync: this,
        changedIndexTo: changedIndexTo);

    for (int i = 0; i < tabContentList.length; i++) {
      tabHeaderList.add(createTab(tabContentList[i]));
    }

    if (returnValue && pSetStateOnChange) {
      setState(() {});
    }

    return returnValue;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> childrenToHide = tabContentList
        .where((e) =>
            !tabController.widgetsSelectedOnce.contains(tabContentList.indexOf(e)) &&
            model.selectedIndex != e.model.indexOf)
        .toList();

    return getPositioned(
      child: Wrap(
        children: [
          FlTabHeader(
            tabHeaderList: tabHeaderList,
            postFrameCallback: postFrameCallback,
            tabController: tabController,
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
          )
        ],
      ),
    );

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
  }

  @override
  void postFrameCallback(BuildContext context) {
    if (lastController != null) {
      lastController!.dispose();
      lastController = null;
    }

    if (tabController.index != model.selectedIndex) {
      tabController.animateTo(model.selectedIndex);
    }

    TabLayout layout = (layoutData.layout as TabLayout);

    double minHeight = (context.findRenderObject() as RenderBox).getMaxIntrinsicHeight(double.infinity).ceilToDouble();
    double tabHeaderHeight = minHeight + 16.0;

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
    String pTabString = pComponent.model.constraints!;

    List pTabStrings = pTabString.split(';');
    bool enabled = (pTabStrings[0]?.toLowerCase() == 'true');
    pComponent.model.isEnabled = enabled;
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

    FlComponentModel childModel = pComponent.model;
    FlLabelModel labelModel = FlLabelModel()
      ..text = text
      ..fontName = childModel.fontName
      ..fontSize = childModel.fontSize
      ..foreground = childModel.foreground
      ..isBold = childModel.isBold
      ..isItalic = childModel.isItalic
      ..verticalAlignment = VerticalAlignment.BOTTOM;

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
                    size: 16,
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
    log("closed tab $index");
  }
}
