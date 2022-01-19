import 'package:flutter/material.dart';
import 'package:flutter_client/src/components/base_wrapper/base_comp_wrapper_widget.dart';
import 'package:flutter_client/src/components/base_wrapper/base_cont_wrapper_state.dart';
import 'package:flutter_client/src/components/split_panel/fl_split_panel_widget.dart';
import 'package:flutter_client/src/layout/split_layout.dart';
import 'package:flutter_client/src/model/component/panel/fl_panel_model.dart';
import 'package:flutter_client/src/model/component/panel/fl_split_panel.dart';

class FlSplitPanelWrapper extends BaseCompWrapperWidget<FlSplitPanelModel> {
  const FlSplitPanelWrapper({Key? key, required FlSplitPanelModel model }) : super(key: key, model: model);

  @override
  _FlSplitPanelWrapperState createState() => _FlSplitPanelWrapperState();
}

class _FlSplitPanelWrapperState extends BaseContWrapperState<FlSplitPanelModel> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var panelWidget = FlSplitPanelWidget(children: children.values.toList());


    return getPositioned(child: panelWidget);

  }
}

