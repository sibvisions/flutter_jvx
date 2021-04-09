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

    double width = TextUtils.getTextWidth(text, fontStyle, textScaleFactor);

    if (columns != null) {
      width = TextUtils.getTextWidth(
              TextUtils.getCharactersWithLength(columns!),
              fontStyle,
              textScaleFactor)
          .toDouble();
    }

    return Size(width + iconWidth + textPadding.horizontal, 50);
  }

  @override
  get isMinimumSizeSet => this.minimumSize != null;

  @override
  get minimumSize {
    double iconWidth = this.enabled ? iconSize + iconPadding.vertical : 0;
    return Size(10 + iconWidth + textPadding.horizontal, 100);
  }
}
