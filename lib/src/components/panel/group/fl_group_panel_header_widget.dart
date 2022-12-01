import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../model/component/panel/fl_group_panel_model.dart';
import '../../../model/response/device_status_response.dart';
import '../../../service/config/i_config_service.dart';
import '../../base_wrapper/fl_stateless_widget.dart';
import '../../label/fl_label_widget.dart';

class FlGroupPanelHeaderWidget<T extends FlGroupPanelModel> extends FlStatelessWidget<T> {
  final Function(BuildContext) postFrameCallback;

  const FlGroupPanelHeaderWidget({
    super.key,
    required super.model,
    required this.postFrameCallback,
  });

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    Widget labelWidget = FlLabelWidget.getTextWidget(
      model,
      pSelectable: true,
    );

    if (model.isFlatStyle) {
      labelWidget = Padding(
        padding: const EdgeInsets.fromLTRB(2, 2, 2, 5),
        child: labelWidget,
      );
    } else {
      labelWidget = Material(
        color: model.background ?? Theme.of(context).colorScheme.primary,
        elevation: 2.0,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: labelWidget,
        ),
      );
    }
    LayoutMode layoutMode = IConfigService().getLayoutMode().value;

    if (layoutMode == LayoutMode.Mini) {
      return labelWidget;
    } else {
      return Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 15),
        child: labelWidget,
      );
    }
  }
}
