import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_client/src/components/panel/group/fl_group_panel_widget.dart';

import '../../../layout/group_layout.dart';
import '../../../layout/i_layout.dart';
import '../../../model/component/panel/fl_group_panel_model.dart';
import '../../base_wrapper/base_comp_wrapper_widget.dart';
import '../../base_wrapper/base_cont_wrapper_state.dart';
import 'fl_group_panel_header_widget.dart';

class FlGroupPanelWrapper extends BaseCompWrapperWidget<FlGroupPanelModel> {
  const FlGroupPanelWrapper({Key? key, required FlGroupPanelModel model}) : super(key: key, model: model);

  @override
  _FlGroupPanelWrapperState createState() => _FlGroupPanelWrapperState();
}

class _FlGroupPanelWrapperState extends BaseContWrapperState<FlGroupPanelModel> {
  bool layoutAfterBuild = false;

  @override
  void initState() {
    super.initState();

    ILayout originalLayout = ILayout.getLayout(model.layout, model.layoutData)!;
    layoutData.layout = GroupLayout(originalLayout: originalLayout, groupHeaderHeight: 0.0);
    layoutData.children = uiService.getChildrenModels(model.id).map((e) => e.id).toList();

    buildChildren();

    layoutAfterBuild = true;
  }

  @override
  receiveNewModel({required FlGroupPanelModel newModel}) {
    ILayout originalLayout = ILayout.getLayout(newModel.layout, newModel.layoutData)!;
    layoutData.layout = GroupLayout(originalLayout: originalLayout, groupHeaderHeight: 0.0);
    super.receiveNewModel(newModel: newModel);

    layoutAfterBuild = true;

    if (!buildChildren()) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return (getPositioned(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FlGroupPanelHeaderWidget(model: model, postFrameCallback: postFrameCallback),
          const Divider(color: Colors.black),
          FlGroupPanelWidget(
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
      layout.groupHeaderHeight = groupHeaderHeight;
      layoutAfterBuild = true;
    }

    if (layoutAfterBuild) {
      registerParent();
      layoutAfterBuild = false;
    }
  }

  double get widthOfGroupPanel {
    double width = 0.0;

    if (layoutData.hasPosition) {
      width = max(width, layoutData.layoutPosition!.width);
    }

    if (layoutData.hasCalculatedSize) {
      width = max(width, layoutData.calculatedSize!.width);
    }

    return width;
  }

  double get heightOfGroupPanel {
    double height = 0.0;

    if (layoutData.hasPosition) {
      height = max(height, layoutData.layoutPosition!.height);
    }

    if (layoutData.hasCalculatedSize) {
      height = max(height, layoutData.calculatedSize!.height);
    }

    if (height > 0.0) {
      height -= (layoutData.layout as GroupLayout).groupHeaderHeight;
    }

    return height;
  }
}
