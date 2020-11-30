import 'package:flutter/material.dart';

import '../../../models/api/component/changed_component.dart';
import '../../../models/api/component/component_properties.dart';
import 'editable_component_model.dart';

class TextComponentModel extends EditableComponentModel {
  bool eventAction = false;
  bool border;
  int horizontalAlignment;
  int columns;
  bool valueChanged = false;
  double iconSize = 24;
  EdgeInsets textPadding = EdgeInsets.fromLTRB(12, 15, 12, 5);
  EdgeInsets iconPadding = EdgeInsets.only(right: 8);

  TextComponentModel(ChangedComponent changedComponent)
      : super(changedComponent);

  void updateProperties(
      BuildContext context, ChangedComponent changedComponent) {
    eventAction = changedComponent.getProperty<bool>(
        ComponentProperty.EVENT_ACTION, eventAction);
    border = changedComponent.getProperty<bool>(ComponentProperty.BORDER, true);
    columns =
        changedComponent.getProperty<int>(ComponentProperty.COLUMNS, columns);
    super.updateProperties(context, changedComponent);
  }

  void onTextFieldValueChanged(dynamic newValue) {
    if (text != newValue) {
      text = newValue;
      this.valueChanged = true;
    }
  }

  void onTextFieldEndEditing() {
    if (this.valueChanged) {
      onComponentValueChanged(this.rawComponentId, text);
      this.valueChanged = false;
    }
  }
}
