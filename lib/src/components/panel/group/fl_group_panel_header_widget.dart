import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../../model/component/label/fl_label_model.dart';
import '../../base_wrapper/fl_stateless_widget.dart';
import '../../label/fl_label_widget.dart';

class FlGroupPanelHeaderWidget<T extends FlLabelModel> extends FlStatelessWidget<T> {
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

    return FlLabelWidget(model: model);
  }
}
