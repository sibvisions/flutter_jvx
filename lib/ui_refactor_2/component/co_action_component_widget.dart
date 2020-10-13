import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/ui_refactor_2/component/component_model.dart';
import 'package:jvx_flutterclient/ui_refactor_2/component/component_widget.dart';

typedef ButtonPressedCallback = void Function(String componentId, String label);

abstract class CoActionComponentWidget extends ComponentWidget {
  CoActionComponentWidget({ComponentModel componentModel})
      : super(componentModel: componentModel);
}

abstract class CoActionComponentWidgetState<T extends CoActionComponentWidget>
    extends ComponentWidgetState<T> {
  ButtonPressedCallback onButtonPressed;

  @override
  void initState() {
    super.initState();
    this.onButtonPressed = widget.componentModel.onButtonPressed;
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
