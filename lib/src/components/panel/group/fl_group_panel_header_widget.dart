import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_client/src/components/base_wrapper/fl_stateless_widget.dart';
import 'package:flutter_client/src/components/label/fl_label_widget.dart';
import 'package:flutter_client/src/model/component/label/fl_label_model.dart';

class FlGroupPanelHeaderWidget<T extends FlLabelModel> extends FlStatelessWidget<T> {
  Function(BuildContext) postFrameCallback;

  FlGroupPanelHeaderWidget({Key? key, required T model, required this.postFrameCallback})
      : super(key: key, model: model);

  @override
  Widget build(BuildContext context) {
    FlLabelWidget labelWidget = FlLabelWidget(model: model);

    SchedulerBinding.instance!.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return labelWidget;
  }
}
