import 'package:flutter/material.dart';
import '../../models/api/component/changed_component.dart';
import '../../models/api/component/component_properties.dart';
import '../../utils/app/text_utils.dart';
import 'component_model.dart';

class LabelComponentModel extends ComponentModel {
  TextStyle style = new TextStyle(fontSize: 16.0, color: Colors.black);
  String text = "";
  ChangedComponent _changedComponent;

  LabelComponentModel(this._changedComponent) : super(_changedComponent) {
    text = _changedComponent.getProperty<String>(ComponentProperty.TEXT, text);
  }

  @override
  get preferredSize {
    double width = TextUtils.getTextWidth(text, style).toDouble();
    return Size(width, 50);
  }
}
