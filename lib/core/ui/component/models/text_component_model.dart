import 'package:flutter/material.dart';

import '../../models/api/component/changed_component.dart';
import '../../models/api/component/component_properties.dart';
import '../../utils/app/text_utils.dart';
import 'editable_component_model.dart';

class TextComponentModel extends EditableComponentModel {
  bool eventAction = false;
  bool border;
  int horizontalAlignment;
  int columns;
  bool valueChanged = false;

  TextComponentModel(ChangedComponent changedComponent)
      : super(changedComponent) {
    eventAction = changedComponent.getProperty<bool>(
        ComponentProperty.EVENT_ACTION, eventAction);
    border = changedComponent.getProperty<bool>(ComponentProperty.BORDER, true);
    columns =
        changedComponent.getProperty<int>(ComponentProperty.COLUMNS, columns);
  }

  @override
  get isPreferredSizeSet => this.preferredSize != null;

  @override
  get preferredSize {
    //if (super.isPreferredSizeSet) return super.preferredSize;

    double width = TextUtils.getTextWidth(text, fontStyle);

    if (columns != null) {
      width = TextUtils.getTextWidth(
              TextUtils.getCharactersWithLength(columns), fontStyle)
          .toDouble();
    }

    return Size(width, 50);
  }

  @override
  get minimumSize {
    return Size(10, 50);
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
