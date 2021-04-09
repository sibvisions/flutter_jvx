import 'package:flutter/material.dart';

import '../../../models/api/response_objects/response_data/component/changed_component.dart';
import '../co_action_component_widget.dart';
import 'component_model.dart';

class ActionComponentModel extends ComponentModel {
  ActionCallback onAction;

  ActionComponentModel(
      {required ChangedComponent changedComponent, required this.onAction})
      : super(changedComponent: changedComponent);

  @override
  void updateProperties(
      BuildContext context, ChangedComponent changedComponent) {
    super.updateProperties(context, changedComponent);
  }
}
