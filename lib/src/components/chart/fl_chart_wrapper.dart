import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_client/src/components/chart/fl_chart_widget.dart';
import 'package:flutter_client/src/mixin/ui_service_mixin.dart';

import '../../mixin/ui_service_mixin.dart';
import '../../model/component/chart/fl_chart_model.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';

class FlChartWrapper extends BaseCompWrapperWidget<FlChartModel> {
  FlChartWrapper({Key? key, required String id}) : super(key: key, id: id);

  @override
  _FlChartWrapperState createState() => _FlChartWrapperState();
}

class _FlChartWrapperState extends BaseCompWrapperState<FlChartModel> with UiServiceMixin {
  @override
  Widget build(BuildContext context) {
    final FlChartWidget widget = FlChartWidget(
      model: model,
    );

    SchedulerBinding.instance!.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: widget);
  }
}
