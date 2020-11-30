import 'dart:math';

import 'package:flutter/material.dart';

import '../../../models/api/component/changed_component.dart';
import '../../../models/api/component/component_properties.dart';
import '../../../utils/app/text_utils.dart';
import 'component_model.dart';

class LabelComponentModel extends ComponentModel {
  TextStyle fontStyle = new TextStyle(fontSize: 16.0, color: Colors.black);

  @override
  get isPreferredSizeSet => this.preferredSize != null;

  @override
  get preferredSize {
    //if (super.isPreferredSizeSet) return super.preferredSize;

    Size size = TextUtils.getTextSize(text, fontStyle);
    return Size(size.width, max(size.height, getBaseline() + 4));
  }

  @override
  get isMinimumSizeSet => this.minimumSize != null;

  @override
  get minimumSize {
    //if (super.isMinimumSizeSet) return super.minimumSize;
    return preferredSize;
  }

  LabelComponentModel(ChangedComponent changedComponent)
      : super(changedComponent);

  @override
  void updateProperties(BuildContext context, ChangedComponent changedComponent) {
    super.updateProperties(context, changedComponent);
    this.text =
        changedComponent.getProperty<String>(ComponentProperty.TEXT, this.text);
  }

  double getBaseline() {
    double labelBaseline = 30;

    if (fontStyle != null && fontStyle.fontSize != null) {
      labelBaseline = fontStyle.fontSize / 2 + 21;
    }

    return labelBaseline;
  }
}
