import 'package:flutter/material.dart';

import '../../api/api_object_property.dart';
import '../fl_component_model.dart';

/// The button model stores all data relevant for the creation of a button.
class FlButtonModel extends FlComponentModel {
  final String text;
  final Color background = Colors.white;
  final Color foreground = Colors.black;
  final TextStyle fontStyle = const TextStyle(fontSize: 16.0, color: Colors.black);
  final double textScaleFactor = 1.0;
  final bool? enabled;

  FlButtonModel.fromJson(Map<String, dynamic> json)
      : text = json[ApiObjectProperty.text],
        enabled = json[ApiObjectProperty.enabled],
        super.fromJson(json);

  FlButtonModel.updatedProperties(FlButtonModel oldModel, dynamic json)
      : text = json[ApiObjectProperty.text] ?? oldModel.text,
        enabled = json[ApiObjectProperty.enabled] ?? oldModel.enabled,
        super.updatedProperties(oldModel, json);

  @override
  FlComponentModel updateComponent(FlComponentModel oldModel, dynamic json) {
    return FlButtonModel.updatedProperties(oldModel as FlButtonModel, json);
  }
}
