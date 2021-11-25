import '../../api/api_object_property.dart';
import '../fl_component_model.dart';

class FlPanelModel extends FlComponentModel {
  final String? layout;
  final String? layoutData;
  final String? screenClassName;

  FlPanelModel.fromJson(Map<String, dynamic> json) :
    layout = json[ApiObjectProperty.layout],
    layoutData = json[ApiObjectProperty.layoutData],
    screenClassName = json[ApiObjectProperty.screenClassName],
    super.fromJson(json);

  FlPanelModel.updatedProperties(FlPanelModel oldModel, dynamic json) :
    layoutData = json[ApiObjectProperty.layoutData] ?? oldModel.layoutData,
    layout = json[ApiObjectProperty.layout] ?? oldModel.layout,
    screenClassName = json[ApiObjectProperty.screenClassName] ?? oldModel.screenClassName,
    super.updatedProperties(oldModel, json);

  @override
  FlComponentModel updateComponent(FlComponentModel oldModel, dynamic json) {
    return FlPanelModel.updatedProperties(oldModel as FlPanelModel, json);
  }
}