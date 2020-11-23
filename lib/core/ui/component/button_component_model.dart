import 'package:flutter/material.dart';

import '../../models/api/component/changed_component.dart';
import '../../models/api/component/component_properties.dart';
import 'action_component_model.dart';

class ButtonComponentModel extends ActionComponentModel {
  Widget icon;
  String style;
  bool network = false;
  Size size = Size(16, 16);
  String image;

  ButtonComponentModel(ChangedComponent changedComponent)
      : super(changedComponent) {
    style =
        changedComponent.getProperty<String>(ComponentProperty.STYLE, style);
    image = changedComponent.getProperty<String>(ComponentProperty.IMAGE);
  }
}
