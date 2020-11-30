import 'package:flutter/material.dart';

import '../../../models/api/component/changed_component.dart';
import '../../../models/api/component/component_properties.dart';
import '../container_component_model.dart';

class GroupPanelComponentModel extends ContainerComponentModel {
  String text = '';

  GroupPanelComponentModel(
      {ChangedComponent changedComponent, String componentId})
      : super(changedComponent: changedComponent, componentId: componentId);

  @override
  void updateProperties(
      BuildContext context, ChangedComponent changedcomponent) {
    super.updateProperties(context, changedcomponent);
    text = changedcomponent.getProperty<String>(ComponentProperty.TEXT, text);
  }
}
