import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../model/component/fl_component_model.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';

class FlCustomWrapper<T extends FlComponentModel> extends BaseCompWrapperWidget<T> {
  FlCustomWrapper({Key? key, required String id}) : super(key: key, id: id);

  @override
  BaseCompWrapperState<FlComponentModel> createState() => _FlCustomWrapperState();
}

class _FlCustomWrapperState extends BaseCompWrapperState<FlComponentModel> {
  late final Widget customWidget;

  @override
  void initState() {
    super.initState();
    customWidget = getUiService().getCustomComponent(pComponentName: model.name)!.componentBuilder.call();
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: customWidget);
  }
}
