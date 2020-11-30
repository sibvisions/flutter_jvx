import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/core/models/api/component/component_properties.dart';
import '../../../../models/api/component/changed_component.dart';
import '../../../../utils/app/text_utils.dart';
import '../../models/component_model.dart';

class MenuItemComponentModel extends ComponentModel {
  bool eventAction = false;

  MenuItemComponentModel(ChangedComponent changedComponent)
      : super(changedComponent);

  @override
  get isPreferredSizeSet => this.preferredSize != null;

  @override
  get preferredSize {
    //if (super.isPreferredSizeSet) return super.preferredSize;

    Size size = TextUtils.getTextSize(text, fontStyle);
    return Size(size.width, size.height);
  }

  @override
  get isMinimumSizeSet => this.minimumSize != null;

  @override
  get minimumSize {
    //if (super.isMinimumSizeSet) return super.minimumSize;
    return preferredSize;
  }

  void updateProperties(BuildContext context, ChangedComponent changedComponent) {
    super.updateProperties(context, changedComponent);

    eventAction = changedComponent.getProperty<bool>(
        ComponentProperty.EVENT_ACTION, eventAction);
  }
}
