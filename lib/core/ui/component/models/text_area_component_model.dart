import 'package:flutter/material.dart';

import '../../../models/api/component/changed_component.dart';
import '../../../utils/app/text_utils.dart';
import 'text_component_model.dart';

class TextAreaComponentModel extends TextComponentModel {
  TextEditingController textController;
  FocusNode focusNode;
  
  TextAreaComponentModel(ChangedComponent changedComponent)
      : super(changedComponent);

  @override
  get isPreferredSizeSet => this.preferredSize != null;

  @override
  get preferredSize {
    //if (super.isPreferredSizeSet) return super.preferredSize;
    double iconWidth = this.enabled ? iconSize + iconPadding.vertical : 0;

    double width = TextUtils.getTextWidth(text, fontStyle);

    if (columns != null) {
      width = TextUtils.getTextWidth(
              TextUtils.getCharactersWithLength(columns), fontStyle)
          .toDouble();
    }

    return Size(width + iconWidth + textPadding.horizontal, 50);
  }

  @override
  get minimumSize {
    //if (super.isMinimumSizeSet) return super.minimumSize;
    double iconWidth = this.enabled ? iconSize + iconPadding.vertical : 0;
    return Size(10 + iconWidth + textPadding.horizontal, 100);
  }
}
