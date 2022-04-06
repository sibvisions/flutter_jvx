import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_client/src/model/layout/layout_data.dart';

import '../../../layout/group_layout.dart';
import '../../../layout/i_layout.dart';
import '../../../model/component/panel/fl_group_panel_model.dart';
import '../../base_wrapper/base_comp_wrapper_widget.dart';
import '../../base_wrapper/base_cont_wrapper_state.dart';
import '../fl_sized_panel_widget.dart';
import 'fl_group_panel_header_widget.dart';

class FlGroupPanelWrapper extends BaseCompWrapperWidget<FlGroupPanelModel> {
  FlGroupPanelWrapper({Key? key, required String id}) : super(key: key, id: id);

  @override
  _FlGroupPanelWrapperState createState() => _FlGroupPanelWrapperState();
}

class _FlGroupPanelWrapperState extends BaseContWrapperState<FlGroupPanelModel> {
  bool layoutAfterBuild = false;

  @override
  void initState() {
    super.initState();

    log("group panel init state");

    ILayout originalLayout = ILayout.getLayout(model.layout, model.layoutData)!;
    layoutData.layout = GroupLayout(originalLayout: originalLayout, groupHeaderHeight: 0.0);
    layoutData.children = uiService.getChildrenModels(model.id).map((e) => e.id).toList();

    layoutAfterBuild = true;

    buildChildren(pSetStateOnChange: false);
  }

  @override
  receiveNewModel({required FlGroupPanelModel newModel}) {
    log("group panel receiveNewModel");

    ILayout originalLayout = ILayout.getLayout(newModel.layout, newModel.layoutData)!;
    layoutData.layout = GroupLayout(originalLayout: originalLayout, groupHeaderHeight: 0.0);
    layoutData.children = uiService.getChildrenModels(model.id).map((e) => e.id).toList();
    super.receiveNewModel(newModel: newModel);

    layoutAfterBuild = true;

    if (!buildChildren()) {
      setState(() {});
    }
  }

  @override
  affected() {
    log("group panel affected");

    layoutAfterBuild = true;

    buildChildren();
  }

  @override
  Widget build(BuildContext context) {
    log("group panel build");

    return (getPositioned(
      child: Wrap(
        children: [
          FlGroupPanelHeaderWidget(model: model, postFrameCallback: postFrameCallback),
          const Divider(color: Colors.black),
          FlSizedPanelWidget(
            children: children.values.toList(),
            width: widthOfGroupPanel,
            height: heightOfGroupPanel,
          ),
        ],
      ),
    ));
  }

  @override
  void postFrameCallback(BuildContext context) {
    GroupLayout layout = (layoutData.layout as GroupLayout);

    double groupHeaderHeight = (context.size != null ? context.size!.height : 0.0) + 16.0;

    if (groupHeaderHeight != layout.groupHeaderHeight) {
      log("group panel layoutAfterBuild is now true | comparison of heigths $groupHeaderHeight ${layout.groupHeaderHeight}");
      layout.groupHeaderHeight = groupHeaderHeight;
      layoutAfterBuild = true;
    }

    if (layoutAfterBuild) {
      log("group panel layoutAfterBuild true");
      layoutAfterBuild = false;
      registerParent();
    }
  }

  double get widthOfGroupPanel {
    if (layoutData.hasPosition) {
      return layoutData.layoutPosition!.width;
    }

    return 0.0;
  }

  double get heightOfGroupPanel {
    if (layoutData.hasPosition) {
      return layoutData.layoutPosition!.height - (layoutData.layout as GroupLayout).groupHeaderHeight;
    }

    return 0.0;
  }

  @override
  receiveNewLayoutData({required LayoutData newLayoutData}) {
    log("received new layout data");
    super.receiveNewLayoutData(newLayoutData: newLayoutData);
  }

  @override
  void registerParent() {
    log("register parent");
    super.registerParent();
  }
}
