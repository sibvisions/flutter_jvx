import 'package:flutter_client/src/model/api/api_object_property.dart';
import 'package:flutter_client/src/model/component/fl_component_model.dart';

class FlPanelModel extends FlComponentModel {
  final String layout;
  final String? layoutData;
  final String? screenClassName;

  FlPanelModel.fromJson(Map<String, dynamic> json) :
    layout = json[ApiObjectProperty.layout],
    layoutData = json[ApiObjectProperty.layoutData],
    screenClassName = json[ApiObjectProperty.screenClassName],
    super.fromJson(json);
}