import 'package:flutter/material.dart';

import '../../../models/api/response_objects/response_data/component/changed_component.dart';
import '../../../models/api/response_objects/response_data/component/component_properties.dart';
import 'editable_component_model.dart';

class TextComponentModel extends EditableComponentModel {
  bool eventAction = false;
  bool? border;
  int columns = 10;
  int rows = 4;
  bool valueChanged = false;
  double iconSize = 24;
  EdgeInsets textPadding = EdgeInsets.fromLTRB(12, 15, 12, 5);
  EdgeInsets iconPadding = EdgeInsets.only(right: 8);
  String placeholder = '';

  TextComponentModel(
      {required ChangedComponent changedComponent,
      required ComponentValueChangedCallback onComponentValueChanged})
      : super(
            changedComponent: changedComponent,
            onComponentValueChanged: onComponentValueChanged);

  void updateProperties(
      BuildContext context, ChangedComponent changedComponent) {
    eventAction = changedComponent.getProperty<bool>(
        ComponentProperty.EVENT_ACTION, eventAction)!;
    border = changedComponent.getProperty<bool>(ComponentProperty.BORDER, true);
    columns =
        changedComponent.getProperty<int>(ComponentProperty.COLUMNS, columns) ??
            columns;
    rows = changedComponent.getProperty<int>(ComponentProperty.COLUMNS, rows) ??
        rows;
    placeholder = changedComponent.getProperty<String>(
        ComponentProperty.PLACEHOLDER, placeholder)!;
    super.updateProperties(context, changedComponent);
  }

  void onTextFieldValueChanged(dynamic newValue) {
    if (text != newValue) {
      text = newValue;
      valueChanged = true;
    }
  }

  void onTextFieldEndEditing(BuildContext context) {
    if (valueChanged && name.isNotEmpty) {
      onComponentValueChanged(context, name, text);
      valueChanged = false;
    }
  }
}
