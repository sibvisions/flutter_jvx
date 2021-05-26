import 'package:flutter/material.dart';

import '../../../models/api/response_objects/response_data/component/changed_component.dart';
import '../../../models/api/response_objects/response_data/component/component_properties.dart';
import 'container_component_model.dart';

class CustomContainerComponentModel extends ContainerComponentModel {
  bool isSignaturePad = false;
  String? dataProvider;
  String? columnName;

  CustomContainerComponentModel({required ChangedComponent changedComponent})
      : super(changedComponent: changedComponent);

  @override
  void updateProperties(
      BuildContext context, ChangedComponent changedComponent) {
    String classNameEventSourceRef = changedComponent.getProperty<String>(
        ComponentProperty.CLASS_NAME_EVENT_SOURCE_REF, '')!;

    if (classNameEventSourceRef == 'SignaturePad') {
      isSignaturePad = true;

      dataProvider = changedComponent.getProperty<String>(
              ComponentProperty.DATA_PROVIDER, null) ??
          changedComponent.getProperty(ComponentProperty.DATA_ROW, null);

      columnName = changedComponent.getProperty<String>(
          ComponentProperty.COLUMN_NAME, null);
    }

    super.updateProperties(context, changedComponent);
  }
}
