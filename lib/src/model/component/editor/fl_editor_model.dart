import '../fl_component_model.dart';

class FlEditorModel extends FlComponentModel {
  Map<String, dynamic> json;

  FlEditorModel({required this.json});

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    // We have to give the editor wrapper all the necessary informations for the layout.
    super.applyFromJson(pJson);
    applyJsonToJson(pJson, json);
  }

  /// Applies component specific layout size information
  applyComponentInformation(FlComponentModel pComponentModel) {
    preferredSize = pComponentModel.preferredSize;
    minimumSize = pComponentModel.minimumSize;
    maximumSize = pComponentModel.maximumSize;
  }

  applyJsonToJson(Map<String, dynamic> pSource, Map<String, dynamic> pDestination) {
    for (String sourceKey in pSource.keys) {
      dynamic value = pSource[sourceKey];

      if (value is Map<String, dynamic>) {
        if (pDestination[sourceKey] == null) {
          pDestination[sourceKey] = Map.from(value);
        } else {
          applyJsonToJson(value, pDestination[sourceKey]);
        }
      } else {
        pDestination[sourceKey] = value;
      }
    }
  }
}
