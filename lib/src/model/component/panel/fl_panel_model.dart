import '../../api/api_object_property.dart';
import '../fl_component_model.dart';

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