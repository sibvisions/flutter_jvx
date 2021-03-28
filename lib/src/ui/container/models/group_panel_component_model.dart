import 'package:flutter/material.dart';
import '../../../models/api/response_objects/response_data/component/changed_component.dart';
import '../../../models/api/response_objects/response_data/component/component_properties.dart';

import 'container_component_model.dart';

class GroupPanelComponentModel extends ContainerComponentModel {
  GroupPanelComponentModel({required ChangedComponent changedComponent})
      : super(changedComponent: changedComponent);

  @override
  void updateProperties(
      BuildContext context, ChangedComponent changedcomponent) {
    super.updateProperties(context, changedcomponent);
    text = changedcomponent.getProperty<String>(ComponentProperty.TEXT, '');
  }
}
