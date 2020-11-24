import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/core/utils/app/text_utils.dart';

import '../../../../models/api/component/changed_component.dart';
import '../../../../models/api/component/component_properties.dart';
import '../../models/component_model.dart';
import '../co_popup_menu_widget.dart';

class PopupButtonComponentModel extends ComponentModel {
  CoPopupMenuWidget menu;
  bool eventAction = false;
  String defaultMenuItem;
  String image;
  Size iconSize = Size(16, 16);

  PopupButtonComponentModel(ChangedComponent changedComponent)
      : super(changedComponent);

  @override
  get preferredSize {
    double width =
        TextUtils.getTextWidth(TextUtils.averageCharactersTextField, fontStyle)
            .toDouble();
    return Size(width, 50);
  }

  @override
  get minimumSize {
    return Size(50, 50);
  }

  void updateProperties(ChangedComponent changedComponent) {
    super.updateProperties(changedComponent);

    eventAction = changedComponent.getProperty<bool>(
        ComponentProperty.EVENT_ACTION, eventAction);
    defaultMenuItem = changedComponent.getProperty<String>(
        ComponentProperty.DEFAULT_MENU_ITEM, defaultMenuItem);
    image = changedComponent.getProperty<String>(ComponentProperty.IMAGE);
  }
}
