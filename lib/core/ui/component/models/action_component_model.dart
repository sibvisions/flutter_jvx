import 'package:flutter/material.dart';

import '../../../models/api/component/changed_component.dart';
import '../../../models/api/so_action.dart';
import '../co_action_component_widget.dart';
import 'component_model.dart';

class ActionComponentModel extends ComponentModel {
  SoAction action;
  ActionCallback onAction;

  ActionComponentModel(ChangedComponent changedComponent)
      : super(changedComponent);

  @override
  void updateProperties(
      BuildContext context, ChangedComponent changedComponent) {
    super.updateProperties(context, changedComponent);

    action = SoAction(componentId: this.name, label: this.text);
  }
}
