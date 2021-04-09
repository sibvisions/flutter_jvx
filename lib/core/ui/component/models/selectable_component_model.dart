import 'package:flutter/material.dart';

import '../../../models/api/component/changed_component.dart';
import '../../../models/api/component/component_properties.dart';
import '../../../utils/app/text_utils.dart';
import 'editable_component_model.dart';

class SelectableComponentModel extends EditableComponentModel {
  bool selected = false;
  bool eventAction = false;

  SelectableComponentModel(ChangedComponent changedComponent)
      : super(changedComponent);

  @override
  get isPreferredSizeSet => this.preferredSize != null;

  @override
  get preferredSize {
    //if (super.isPreferredSizeSet) return super.preferredSize;
    double checkSize = 48;

    Size size = TextUtils.getTextSize(text, fontStyle, textScaleFactor);
    return Size(size.width + checkSize, checkSize);
  }

  void updateProperties(
      BuildContext context, ChangedComponent changedComponent) {
    super.updateProperties(context, changedComponent);

    eventAction = changedComponent.getProperty<bool>(
        ComponentProperty.EVENT_ACTION, eventAction);
    selected = changedComponent.getProperty<bool>(
        ComponentProperty.SELECTED, selected);
  }
}
