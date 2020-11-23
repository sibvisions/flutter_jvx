import 'package:flutter/material.dart';
import '../../models/api/component/changed_component.dart';
import '../../models/api/component/component_properties.dart';
import '../../utils/app/text_utils.dart';
import 'component_model.dart';

class LabelComponentModel extends ComponentModel {
  TextStyle style = new TextStyle(fontSize: 16.0, color: Colors.black);
  ChangedComponent _changedComponent;

  LabelComponentModel(this._changedComponent) : super(_changedComponent) {}

  @override
  get preferredSize {
    Size size = TextUtils.getTextSize(text, style);
    return Size(size.width, size.height);
  }
}
