import '../../api/api_object_property.dart';
import '../fl_component_model.dart';

class FlLabelModel extends FlComponentModel {
  final String text;

  FlLabelModel.fromJson(Map<String, dynamic> json)
      : text = json[ApiObjectProperty.text],
        super.fromJson(json);

  FlLabelModel.updatedProperties(FlLabelModel oldModel, dynamic json)
      : text = json[ApiObjectProperty.text] ?? oldModel.text,
        super.updatedProperties(oldModel, json);

  @override
  FlComponentModel updateComponent(FlComponentModel oldModel, json) {
    return FlLabelModel.updatedProperties(oldModel as FlLabelModel, json);
  }
}
