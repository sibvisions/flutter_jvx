import 'package:flutter/material.dart';

import '../../../models/api/component/changed_component.dart';
import '../../../utils/app/text_utils.dart';
import 'text_component_model.dart';

class TextFieldComponentModel extends TextComponentModel {
  TextFieldComponentModel(ChangedComponent changedComponent)
      : super(changedComponent);

  @override
  get isPreferredSizeSet => this.preferredSize != null;

  @override
  get preferredSize {
    //if (super.isPreferredSizeSet) return super.preferredSize;

    double width = TextUtils.getTextWidth(text, fontStyle);

    if (columns != null) {
      width = TextUtils.getTextWidth(
              TextUtils.getCharactersWithLength(columns), fontStyle)
          .toDouble();
    }

    return Size(width, 50);
  }

  @override
  get minimumSize {
    return Size(10, 50);
  }
}
