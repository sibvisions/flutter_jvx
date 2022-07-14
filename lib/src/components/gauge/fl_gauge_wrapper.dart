import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../model/component/gauge/fl_gauge_model.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';
import 'fl_gauge_widget.dart';

class FlGaugeWrapper extends BaseCompWrapperWidget<FlGaugeModel> {
  FlGaugeWrapper({Key? key, required String id}) : super(key: key, id: id);

  @override
  _FlGaugeWrapperState createState() => _FlGaugeWrapperState();
}

class _FlGaugeWrapperState extends BaseCompWrapperState<FlGaugeModel> {
  @override
  Widget build(BuildContext context) {
    final FlGaugeWidget widget = FlGaugeWidget(model: model);

    SchedulerBinding.instance!.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: widget);
  }
}
