import 'package:flutter/material.dart';

import '../../../../models/api/response_objects/response_data/component/changed_component.dart';
import '../../../../models/api/response_objects/response_data/component/component_properties.dart';
import '../../../../util/app/text_utils.dart';
import '../../model/component_model.dart';

class MenuItemComponentModel extends ComponentModel {
  bool eventAction = false;

  MenuItemComponentModel({required ChangedComponent changedComponent})
      : super(changedComponent: changedComponent);

  @override
  get isPreferredSizeSet => this.preferredSize != null;

  @override
  get preferredSize {
    Size size = TextUtils.getTextSize(text, fontStyle);
    return Size(size.width, size.height);
  }

  @override
  get isMinimumSizeSet => this.minimumSize != null;

  @override
  get minimumSize {
    return preferredSize;
  }

  void updateProperties(
      BuildContext context, ChangedComponent changedComponent) {
    super.updateProperties(context, changedComponent);

    eventAction = changedComponent.getProperty<bool>(
        ComponentProperty.EVENT_ACTION, eventAction)!;
  }
}
