import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../model/component/dummy/fl_dummy_model.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';

import 'fl_dummy_widget.dart';

class FlDummyWrapper extends BaseCompWrapperWidget<FlDummyModel> {
  const FlDummyWrapper({Key? key, required FlDummyModel model}) : super(key: key, model: model);

  @override
  _FlDummyWrapperState createState() => _FlDummyWrapperState();
}

class _FlDummyWrapperState extends BaseCompWrapperState<FlDummyModel> {
  @override
  Widget build(BuildContext context) {
    FlDummyWidget dummyWidget = FlDummyWidget(
      model: model,
      height: getHeightForComponent(),
      width: getWidthForComponent(),
      key: Key("${model.id}_Widget"),
    );

    SchedulerBinding.instance!.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: dummyWidget);
  }
}
