import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/core/models/api/component/changed_component.dart';
import 'package:jvx_flutterclient/core/models/api/component/component_properties.dart';
import 'package:jvx_flutterclient/core/ui/component/models/action_component_model.dart';

class ToggleButtonComponentModel extends ActionComponentModel {
  Widget icon;
  String style;
  bool network = false;
  Size iconSize = Size(16, 16);
  double iconPadding = 10;
  EdgeInsets margin = EdgeInsets.all(4);
  String image;
  String textStyle;

  Color disabledColor;
  bool selected = false;

  ToggleButtonComponentModel(ChangedComponent changedComponent)
      : super(changedComponent);

  @override
  void updateProperties(
      BuildContext context, ChangedComponent changedComponent) {
    image = changedComponent.getProperty<String>(ComponentProperty.IMAGE);
    text = changedComponent.getProperty<String>(ComponentProperty.TEXT, text);
    textStyle = changedComponent.getProperty<String>(
        ComponentProperty.STYLE, textStyle);

    bool newSelected =
        changedComponent.getProperty<bool>(ComponentProperty.SELECTED);
    if (newSelected != null) {
      selected = newSelected;
    }

    super.updateProperties(context, changedComponent);
  }
}
