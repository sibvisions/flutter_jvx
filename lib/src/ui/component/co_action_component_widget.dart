import 'package:flutter/material.dart';

import 'component_widget.dart';
import 'model/action_component_model.dart';

typedef ActionCallback = void Function(
    BuildContext context, String componentId);

abstract class CoActionComponentWidget extends ComponentWidget {
  final ActionComponentModel componentModel;

  CoActionComponentWidget({required this.componentModel})
      : super(componentModel: componentModel);
}

abstract class CoActionComponentWidgetState<T extends CoActionComponentWidget>
    extends ComponentWidgetState<T> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
