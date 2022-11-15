import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../../util/parse_util.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/component/label/fl_label_model.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';
import 'fl_label_widget.dart';

class FlLabelWrapper extends BaseCompWrapperWidget<FlLabelModel> {
  const FlLabelWrapper({super.key, required super.id});

  @override
  BaseCompWrapperState<FlComponentModel> createState() => _FlLabelWrapperState();
}

class _FlLabelWrapperState extends BaseCompWrapperState<FlLabelModel> {
  @override
  Widget build(BuildContext context) {
    final FlLabelWidget widget = FlLabelWidget(model: model);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: widget);
  }

  @override
  Size calculateSize(BuildContext context) {
    if (ParseUtil.isHTML(model.text)) {
      return const Size(400, 100);
    }
    double minWidth = (context.findRenderObject() as RenderBox).getMaxIntrinsicWidth(double.infinity).ceilToDouble();
    double minHeight = (context.findRenderObject() as RenderBox).getMaxIntrinsicHeight(double.infinity).ceilToDouble();
    return Size(minWidth, minHeight);
  }
}
