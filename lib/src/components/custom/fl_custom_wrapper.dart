import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../custom/app_manager.dart';
import '../../custom/custom_component.dart';
import '../../model/component/fl_component_model.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';

/// A custom wrapper is a component wrapper which wraps widgets which were added or replaced via the [AppManager].
class FlCustomWrapper<M extends FlComponentModel> extends BaseCompWrapperWidget<M> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final CustomComponent customComponent;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlCustomWrapper({super.key, required super.id, required this.customComponent});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlCustomWrapperState<M> createState() => FlCustomWrapperState();
}

class FlCustomWrapperState<M extends FlComponentModel> extends BaseCompWrapperState<M> {
  FlCustomWrapperState() : super();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: (widget as FlCustomWrapper).customComponent.componentBuilder.call());
  }
}
