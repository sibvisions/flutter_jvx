import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../model/component/dummy/fl_dummy_model.dart';
import '../../model/component/fl_component_model.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';
import 'fl_dummy_widget.dart';

class FlDummyWrapper<T extends FlDummyModel> extends BaseCompWrapperWidget<T> {
  const FlDummyWrapper({Key? key, required String id}) : super(key: key, id: id);

  @override
  BaseCompWrapperState<FlComponentModel> createState() => _FlDummyWrapperState();
}

class _FlDummyWrapperState extends BaseCompWrapperState<FlDummyModel> {
  @override
  Widget build(BuildContext context) {
    FlDummyWidget dummyWidget = FlDummyWidget(
      model: model,
      key: Key("${model.id}_Widget"),
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: dummyWidget);
  }
}
