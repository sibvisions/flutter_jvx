import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_client/src/layout/i_layout.dart';
import 'package:flutter_client/src/layout/scroll_layout.dart';

import '../../model/component/panel/fl_panel_model.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';
import '../base_wrapper/base_cont_wrapper_state.dart';
import 'fl_panel_widget.dart';
import 'fl_scroll_panel_widget.dart';

class FlScrollPanelWrapper extends BaseCompWrapperWidget<FlPanelModel> {
  const FlScrollPanelWrapper({Key? key, required FlPanelModel model}) : super(key: key, model: model);

  @override
  _FlPanelWrapperState createState() => _FlPanelWrapperState();
}

class _FlPanelWrapperState extends BaseContWrapperState<FlPanelModel> {
  @override
  void initState() {
    super.initState();

    ILayout originalLayout = ILayout.getLayout(model.layout, model.layoutData)!;

    layoutData.layout = ScrollLayout(originalLayout);
    layoutData.children = uiService.getChildrenModels(model.id).map((e) => e.id).toList();
    layoutData.insets = const EdgeInsets.only();

    registerParent();
    buildChildren();
  }

  @override
  receiveNewModel({required FlPanelModel newModel}) {
    ILayout originalLayout = ILayout.getLayout(newModel.layout, newModel.layoutData)!;
    layoutData.layout = ScrollLayout(originalLayout);
    super.receiveNewModel(newModel: newModel);

    buildChildren();
    registerParent();
  }

  @override
  Widget build(BuildContext context) {
    FlScrollPanelWidget panelWidget = FlScrollPanelWidget(
      children: children.values.toList(),
      width: widthOfScrollPanel,
      height: heightOfScrollPanel,
    );

    return (getPositioned(child: panelWidget));
  }

  double get widthOfScrollPanel {
    double width = 0.0;

    if (layoutData.hasPosition) {
      width = max(width, layoutData.layoutPosition!.width);
    }

    if (layoutData.hasCalculatedSize) {
      width = max(width, layoutData.calculatedSize!.width);
    }

    return width;
  }

  double get heightOfScrollPanel {
    double height = 0.0;

    if (layoutData.hasPosition) {
      height = max(height, layoutData.layoutPosition!.height);
    }

    if (layoutData.hasCalculatedSize) {
      height = max(height, layoutData.calculatedSize!.height);
    }

    return height;
  }
}
