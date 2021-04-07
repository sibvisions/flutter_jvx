import 'package:flutter/material.dart';

import '../../../models/api/response_objects/response_data/component/changed_component.dart';
import 'component_model.dart';

typedef ComponentValueChangedCallback = void Function(
    BuildContext context, String componentId, dynamic value);

class EditableComponentModel extends ComponentModel {
  ComponentValueChangedCallback onComponentValueChanged;

  EditableComponentModel(
      {required ChangedComponent changedComponent,
      required this.onComponentValueChanged})
      : super(changedComponent: changedComponent);
}
