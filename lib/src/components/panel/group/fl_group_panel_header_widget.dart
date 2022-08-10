import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';

import '../../../model/component/label/fl_label_model.dart';
import '../../base_wrapper/fl_stateless_widget.dart';
import '../../label/fl_label_widget.dart';

class FlGroupPanelHeaderWidget<T extends FlLabelModel> extends FlStatelessWidget<T> {
  final Function(BuildContext) postFrameCallback;

  const FlGroupPanelHeaderWidget({Key? key, required T model, required this.postFrameCallback})
      : super(key: key, model: model);

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return FlLabelWidget(model: model);
  }
}
