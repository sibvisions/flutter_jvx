import 'package:flutter/material.dart';

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
  Widget build(BuildContext context) {
    FlScrollPanelWidget panelWidget = FlScrollPanelWidget(
      children: children.values.toList(),
      width: layoutData.hasCalculatedSize ? layoutData.calculatedSize!.width : 0.0,
      height: layoutData.hasCalculatedSize ? layoutData.calculatedSize!.height : 0.0,
    );

    return (getPositioned(child: panelWidget));
  }
}
