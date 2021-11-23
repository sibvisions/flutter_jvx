import 'package:flutter_client/src/model/api/api_object_property.dart';
import 'package:flutter_client/src/model/component/fl_component_model.dart';

class FlButtonModel extends FlComponentModel {

  final String text;

  FlButtonModel.fromJson(Map<String, dynamic> json) :
    text = json[ApiObjectProperty.text],
    super.fromJson(json);
}