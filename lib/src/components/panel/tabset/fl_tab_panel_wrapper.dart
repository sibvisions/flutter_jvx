import 'package:flutter/material.dart';
import 'package:flutter_client/src/components/label/fl_label_widget.dart';
import 'package:flutter_client/src/components/panel/fl_sized_panel_widget.dart';
import 'package:flutter_client/src/components/panel/tabset/fl_tab_header.dart';
import 'package:flutter_client/src/layout/tab_layout.dart';
import 'package:flutter_client/src/model/component/label/fl_label_model.dart';
import 'package:flutter_client/src/model/component/panel/fl_tab_panel_model.dart';
import 'package:flutter_client/util/constants/i_color.dart';
import 'package:flutter_client/util/font_awesome_util.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../base_wrapper/base_comp_wrapper_widget.dart';
import '../../base_wrapper/base_cont_wrapper_state.dart';

class FlTabPanelWrapper extends BaseCompWrapperWidget<FlTabPanelModel> {
  const FlTabPanelWrapper({Key? key, required FlTabPanelModel model}) : super(key: key, model: model);

  @override
  _FlTabPanelWrapperState createState() => _FlTabPanelWrapperState();
}

class _FlTabPanelWrapperState extends BaseContWrapperState<FlTabPanelModel> with TickerProviderStateMixin {
  late TabController tabController;

  bool layoutAfterBuild = false;

  List<Widget> tabHeaderList = [];
  List<BaseCompWrapperWidget> tabContentList = [];

  @override
  void initState() {
    super.initState();

    layoutData.layout = TabLayout(tabHeaderHeight: 0.0, selectedIndex: model.selectedIndex);
    layoutData.children = uiService.getChildrenModels(model.id).map((e) => e.id).toList();

    layoutAfterBuild = true;

    buildChildren();
  }

  @override
  receiveNewModel({required FlTabPanelModel newModel}) {
    layoutData.layout = TabLayout(tabHeaderHeight: 0.0, selectedIndex: model.selectedIndex);
    super.receiveNewModel(newModel: newModel);

    layoutAfterBuild = true;

    if (!buildChildren()) {
      setState(() {});
    }
  }

  @override
  affected() {
    layoutAfterBuild = true;

    buildChildren();
  }

  @override
  bool buildChildren() {
    bool layoutAfterBuildBefore = layoutAfterBuild;
    layoutAfterBuild = false;

    bool returnValue = super.buildChildren();

    tabHeaderList.clear();
    tabContentList.clear();

    /// Sort children by index;
    for (Widget child in children.values) {
      if (child is BaseCompWrapperWidget) {
        tabContentList.add(child);
      }
    }

    tabContentList.sort((a, b) => a.model.indexOf - b.model.indexOf);

    for (int i = 0; i < tabContentList.length; i++) {
      tabHeaderList.add(createTab(tabContentList[i]));
    }

    tabController = TabController(length: tabHeaderList.length, vsync: this);

    if (returnValue) {
      layoutAfterBuild = layoutAfterBuildBefore;
      setState(() {});
    }

    return returnValue;
  }

  @override
  Widget build(BuildContext context) {
    List<BaseCompWrapperWidget> childrenList = [];

    for (Widget child in children.values) {
      if (child is BaseCompWrapperWidget) {
        childrenList.add(child);
      }
    }

    return (getPositioned(
      child: Wrap(children: [
        FlTabHeader(
          tabHeaderList: tabHeaderList,
          postFrameCallback: postFrameCallback,
        ),
        FlSizedPanelWidget(
          children: tabContentList,
          width: widthOfTabPanel,
          height: heightOfTabPanel,
        ),
      ]),
    ));
  }

  @override
  void postFrameCallback(BuildContext context) {
    TabLayout layout = (layoutData.layout as TabLayout);

    double tabHeaderHeight = (context.size != null ? context.size!.height : 0.0) + 16.0;

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

    Widget textChild;
    var model = pComponent.model;
    if (model is FlLabelModel) {
      model.text = text;
      textChild = FlLabelWidget(model: model);
    } else {
      textChild = FlLabelWidget(model: FlLabelModel()..text = text);
    }

    return GestureDetector(
      onTap: enabled
          ? () {
              selectTab(model.indexOf);
            }
          : null,
      child: Tab(
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
                            closeTab(model.indexOf);
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
      ),
    );
  }

  void closeTab(int index) {
    // if (index > 0) {
    //   setState(() {
    //     pendingDeletes.add(index);
    //     tabController.animateTo(0);
    //   });
    // }
  }

  void selectTab(int index) {}
}
