import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../model/component/fl_component_model.dart';
import '../../service/ui/i_ui_service.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';

class FlCustomWrapper<T extends FlComponentModel> extends BaseCompWrapperWidget<T> {
  const FlCustomWrapper({super.key, required super.id});

  @override
  BaseCompWrapperState<FlComponentModel> createState() => _FlCustomWrapperState();
}

class _FlCustomWrapperState extends BaseCompWrapperState<FlComponentModel> {
  late final Widget customWidget;

  @override
  void initState() {
    super.initState();
    customWidget = IUiService().getCustomComponent(pComponentName: model.name)!.componentBuilder.call();
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: customWidget);
  }
}
