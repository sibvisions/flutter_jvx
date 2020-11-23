import 'package:flutter/material.dart';

import '../../../models/api/component/changed_component.dart';
import '../../../models/api/component/component_properties.dart';
import '../../../utils/app/text_utils.dart';
import 'action_component_model.dart';

class ButtonComponentModel extends ActionComponentModel {
  Widget icon;
  String style;
  bool network = false;
  Size iconSize = Size(16, 16);
  double iconPadding = 10;
  EdgeInsets margin = EdgeInsets.all(4);
  String image;

  ButtonComponentModel(ChangedComponent changedComponent)
      : super(changedComponent);

  @override
  get isPreferredSizeSet => this.preferredSize != null;

  @override
  get preferredSize {
    //if (super.isPreferredSizeSet) return super.preferredSize;
    double width = 30;
    double height = 30;

    if (this.image != null) {
      width += iconSize.width + iconPadding;
    }

    if (this.style == 'hyperlink') height = 20;

    Size size = TextUtils.getTextSize(text, fontStyle);
    return Size(size.width + width + margin.horizontal,
        size.height + height + margin.vertical);
  }

  void updateProperties(ChangedComponent changedComponent) {
    super.updateProperties(changedComponent);

    style =
        changedComponent.getProperty<String>(ComponentProperty.STYLE, style);
    image = changedComponent.getProperty<String>(ComponentProperty.IMAGE);
  }
}
