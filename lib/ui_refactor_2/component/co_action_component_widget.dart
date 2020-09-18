import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/ui_refactor_2/component/component_model.dart';
import 'package:jvx_flutterclient/ui_refactor_2/component/component_widget.dart';

typedef ButtonPressedCallback = void Function(String componentId, String label);

abstract class CoActionComponentWidget extends ComponentWidget {
  CoActionComponentWidget({Key key, ComponentModel componentModel})
      : super(key: key, componentModel: componentModel);
}

abstract class CoActionComponentWidgetState<T extends CoActionComponentWidget>
    extends ComponentWidgetState<T> {
  ButtonPressedCallback onButtonPressed;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
