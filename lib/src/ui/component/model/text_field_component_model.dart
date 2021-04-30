import 'package:flutter/material.dart';
import 'package:flutterclient/src/models/api/response_objects/response_data/component/changed_component.dart';
import 'package:flutterclient/src/util/app/text_utils.dart';

import 'editable_component_model.dart';
import 'text_component_model.dart';

class TextFieldComponentModel extends TextComponentModel {
  TextFieldComponentModel(
      {required ChangedComponent changedComponent,
      required ComponentValueChangedCallback onComponentValueChanged})
      : super(
            changedComponent: changedComponent,
            onComponentValueChanged: onComponentValueChanged);

  @override
  get isPreferredSizeSet => this.preferredSize != null;

  @override
  get preferredSize {
    double iconWidth = this.enabled ? iconSize + iconPadding.vertical : 0;

    Size size = TextUtils.getTextFieldSize(
        text, columns, rows, false, fontStyle, textScaleFactor);
    return Size(
        18 + size.width + iconWidth + textPadding.horizontal, size.height + 31);
  }

  @override
  get isMinimumSizeSet => this.minimumSize != null;

  @override
  get minimumSize {
    double iconWidth = this.enabled ? iconSize + iconPadding.vertical : 0;
    return Size(10 + iconWidth + textPadding.horizontal, 100);
  }
}
