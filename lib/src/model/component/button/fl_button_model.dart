import '../../api/api_object_property.dart';
import '../fl_component_model.dart';

class FlButtonModel extends FlComponentModel {
  final String text;

  FlButtonModel.fromJson(Map<String, dynamic> json) :
    text = json[ApiObjectProperty.text],
    super.fromJson(json);


  FlButtonModel.updatedProperties(FlButtonModel oldModel, dynamic json) :
      text = json[ApiObjectProperty.text] ?? oldModel.text,
      super.updatedProperties(oldModel, json);

  @override
  FlComponentModel updateComponent(FlComponentModel oldModel, dynamic json) {
    return FlButtonModel.updatedProperties(oldModel as FlButtonModel, json);
  }


}