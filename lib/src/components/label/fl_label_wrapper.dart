import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_client/src/components/base_wrapper/base_comp_wrapper_state.dart';
import 'package:flutter_client/src/components/base_wrapper/base_comp_wrapper_widget.dart';
import 'package:flutter_client/src/components/label/fl_label_widget.dart';
import 'package:flutter_client/src/model/component/label/fl_label_model.dart';

class FlLabelWrapper extends BaseCompWrapperWidget<FlLabelModel> {
  const FlLabelWrapper({Key? key, required FlLabelModel model}) : super(key: key, model: model);

  @override
  _FlLabelWrapperState createState() => _FlLabelWrapperState();
}

class _FlLabelWrapperState extends BaseCompWrapperState<FlLabelModel> {

  @override
  Widget build(BuildContext context) {

    final FlLabelWidget widget = FlLabelWidget(model: model);
    
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      postFrameCallback(timeStamp, context);
    });

    return getPositioned(child: widget);
  }
}
