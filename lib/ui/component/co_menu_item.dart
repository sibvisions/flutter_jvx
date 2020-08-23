import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/ui/screen/so_component_creator.dart';
import '../../model/changed_component.dart';
import '../../model/properties/component_properties.dart';
import 'i_component.dart';
import 'component.dart';

class CoMenuItem extends Component implements IComponent {
  String text;
  bool eventAction = false;

  CoMenuItem(GlobalKey componentId, BuildContext context)
      : super(componentId, context);

  factory CoMenuItem.withCompContext(ComponentContext componentContext) {
    return CoMenuItem(componentContext.globalKey, componentContext.context);
  }

  void updateProperties(ChangedComponent changedProperties) {
    super.updateProperties(changedProperties);
    text = changedProperties.getProperty<String>(ComponentProperty.TEXT, text);
    eventAction = changedProperties.getProperty<bool>(
        ComponentProperty.EVENT_ACTION, eventAction);
  }

  @override
  Widget getWidget() {
    return null;
  }
}
