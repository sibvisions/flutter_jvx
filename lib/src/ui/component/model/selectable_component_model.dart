import 'package:flutter/material.dart';

import '../../../models/api/response_objects/response_data/component/changed_component.dart';
import '../../../models/api/response_objects/response_data/component/component_properties.dart';
import '../../../util/app/text_utils.dart';
import 'editable_component_model.dart';

class SelectableComponentModel extends EditableComponentModel {
  bool selected = false;
  bool eventAction = false;

  SelectableComponentModel(
      {required ChangedComponent changedComponent,
      required ComponentValueChangedCallback onComponentValueChanged})
      : super(
            changedComponent: changedComponent,
            onComponentValueChanged: onComponentValueChanged);

  @override
  get isPreferredSizeSet => this.preferredSize != null;

  @override
  get preferredSize {
    double checkSize = 48;

    Size size = TextUtils.getTextSize(text, fontStyle);
    return Size(size.width + checkSize, checkSize);
  }

  void updateProperties(
      BuildContext context, ChangedComponent changedComponent) {
    super.updateProperties(context, changedComponent);

    eventAction = changedComponent.getProperty<bool>(
        ComponentProperty.EVENT_ACTION, eventAction)!;
    selected = changedComponent.getProperty<bool>(
        ComponentProperty.SELECTED, selected)!;
  }
}
