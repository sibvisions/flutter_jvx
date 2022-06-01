import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_client/src/components/base_wrapper/base_comp_wrapper_state.dart';
import 'package:flutter_client/src/components/base_wrapper/base_comp_wrapper_widget.dart';
import 'package:flutter_client/src/model/component/fl_component_model.dart';

class FlCustomWrapper<T extends FlComponentModel> extends BaseCompWrapperWidget<T> {
  FlCustomWrapper({Key? key, required String id}) : super(key: key, id: id);

  @override
  _FlCustomWrapperState createState() => _FlCustomWrapperState();
}

class _FlCustomWrapperState extends BaseCompWrapperState<FlComponentModel> {
  late final Widget customWidget;

  @override
  void initState() {
    super.initState();
    customWidget = uiService.getCustomComponent(pComponentName: model.name)!.componentFactory.call();
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: customWidget);
  }
}
