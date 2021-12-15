import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_client/src/components/base_wrapper/base_comp_wrapper_state.dart';
import 'package:flutter_client/src/components/base_wrapper/base_comp_wrapper_widget.dart';
import 'package:flutter_client/src/model/component/fl_component_model.dart';

import 'dummy_widget.dart';

class DummyWrapper extends BaseCompWrapperWidget {
  const DummyWrapper({Key? key, required FlComponentModel model}) : super(key: key, model: model);

  @override
  _DummyWrapperState createState() => _DummyWrapperState();
}

class _DummyWrapperState extends BaseCompWrapperState {


  @override
  Widget build(BuildContext context) {
    DummyWidget dummyWidget = DummyWidget(
      height: getHeightForComponent(),
      width: getWidthForComponent(),
    );

    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      postFrameCallback(timeStamp, context);
    });

    return getPositioned(child: dummyWidget);
  }
}
