import 'package:flutter/material.dart';

import '../../../models/api/response_objects/response_data/component/changed_component.dart';
import '../../../models/api/response_objects/response_data/component/component_properties.dart';
import '../../../util/app/so_text_align.dart';
import '../../../util/app/text_utils.dart';
import '../co_action_component_widget.dart';
import 'action_component_model.dart';

class ButtonComponentModel extends ActionComponentModel {
  Widget? icon;
  String? style;
  bool network = false;
  Size iconSize = Size(16, 16);
  double iconPadding = 10;
  EdgeInsets margin = EdgeInsets.all(0);
  String? image;
  int? _horizontalTextPosition;

  TextAlign get horizontalTextPosition {
    if (_horizontalTextPosition != null)
      return SoTextAlign.getTextAlignFromInt(_horizontalTextPosition!);
    return TextAlign.center;
  }

  ButtonComponentModel(
      {required ChangedComponent changedComponent,
      required ActionCallback onAction})
      : super(changedComponent: changedComponent, onAction: onAction);

  @override
  get isPreferredSizeSet => this.preferredSize != null;

  @override
  get preferredSize {
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

  @override
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
