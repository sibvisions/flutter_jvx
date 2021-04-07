import 'package:flutter/material.dart';

import '../../../models/api/response_objects/response_data/component/changed_component.dart';
import '../../../models/api/response_objects/response_data/component/component_properties.dart';
import '../co_action_component_widget.dart';
import 'action_component_model.dart';

class ToggleButtonComponentModel extends ActionComponentModel {
  Widget? icon;
  String? style;
  bool network = false;
  Size iconSize = Size(16, 16);
  double iconPadding = 10;
  EdgeInsets margin = EdgeInsets.all(4);
  String? image;
  String? textStyle;

  Color? disabledColor;
  bool selected = false;

  ToggleButtonComponentModel(
      {required ChangedComponent changedComponent,
      required ActionCallback onAction})
      : super(changedComponent: changedComponent, onAction: onAction);

  @override
  void updateProperties(
      BuildContext context, ChangedComponent changedComponent) {
    image =
        changedComponent.getProperty<String>(ComponentProperty.IMAGE, image);
    text = changedComponent.getProperty<String>(ComponentProperty.TEXT, text);
    textStyle = changedComponent.getProperty<String>(
        ComponentProperty.STYLE, textStyle);

    bool? newSelected =
        changedComponent.getProperty<bool>(ComponentProperty.SELECTED, null);

    if (newSelected != null) {
      selected = newSelected;
    }

    super.updateProperties(context, changedComponent);
  }
}
