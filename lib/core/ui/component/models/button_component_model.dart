import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/core/utils/app/so_text_align.dart';

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
  int _horizontalTextPosition;

  TextAlign get horizontalTextPosition {
    if (_horizontalTextPosition != null)
      return SoTextAlign.getTextAlignFromInt(_horizontalTextPosition);
    return TextAlign.center;
  }

  ButtonComponentModel(ChangedComponent changedComponent)
      : super(changedComponent);

  @override
  get isPreferredSizeSet => this.preferredSize != null;

  @override
  get preferredSize {
    //if (super.isPreferredSizeSet) return super.preferredSize;
    double width = 35;
    double height = 30;

    if (this.image != null) {
      width += iconSize.width + iconPadding;
    }

    if (this.style == 'hyperlink') height = 20;

    Size size = TextUtils.getTextSize(text, fontStyle);
    return Size(size.width + width + margin.horizontal,
        size.height + height + margin.vertical);
  }

  void updateProperties(
      BuildContext context, ChangedComponent changedComponent) {
    style =
        changedComponent.getProperty<String>(ComponentProperty.STYLE, style);
    image =
        changedComponent.getProperty<String>(ComponentProperty.IMAGE, image);
    _horizontalTextPosition = changedComponent.getProperty<int>(
        ComponentProperty.HORIZONTAL_TEXT_POSITION, _horizontalTextPosition);

    super.updateProperties(context, changedComponent);
  }
}
