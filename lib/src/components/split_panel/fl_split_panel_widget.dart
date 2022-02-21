import 'package:flutter/material.dart';
import 'package:flutter_client/src/components/base_wrapper/base_comp_wrapper_widget.dart';
import 'package:flutter_client/src/components/base_wrapper/fl_stateless_widget.dart';
import 'package:flutter_client/src/mixin/ui_service_mixin.dart';
import 'package:flutter_client/src/model/component/panel/fl_split_panel_model.dart';
import 'package:flutter_client/src/model/layout/layout_data.dart';
import 'package:flutter_client/util/extensions/list_extensions.dart';

class FlSplitPanelWidget extends FlStatelessWidget<FlSplitPanelModel> with UiServiceMixin {
  FlSplitPanelWidget({Key? key, required FlSplitPanelModel model, required this.children})
      : super(key: key, model: model);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: children,
    );
  }
}
