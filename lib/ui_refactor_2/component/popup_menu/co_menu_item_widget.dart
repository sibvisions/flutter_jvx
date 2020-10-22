import 'package:flutter/material.dart';

import '../../../model/changed_component.dart';
import '../../../model/properties/component_properties.dart';
import '../component_model.dart';
import '../component_widget.dart';

class CoMenuItemWidget extends ComponentWidget {
  CoMenuItemWidget({Key key, ComponentModel componentModel})
      : super(key: key, componentModel: componentModel);

  @override
  State<StatefulWidget> createState() => CoMenuItemWidgetState();
}

class CoMenuItemWidgetState extends ComponentWidgetState<CoMenuItemWidget> {
  String text;
  bool eventAction = false;

  @override
  void updateProperties(ChangedComponent changedProperties) {
    super.updateProperties(changedProperties);
    text = changedProperties.getProperty<String>(ComponentProperty.TEXT, text);
    eventAction = changedProperties.getProperty<bool>(
        ComponentProperty.EVENT_ACTION, eventAction);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuItem<String>(
        value: name, child: Text(text), enabled: enabled);
  }
}
