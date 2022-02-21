import 'package:flutter_client/src/model/api/api_object_property.dart';

import '../fl_component_model.dart';

class FlEditorModel extends FlComponentModel {
  late String dataRow;

  late String columnName;

  Map<String, dynamic> json;

  //ICellEditor cellEditor = FlDummyCellEditor(pCellEditorJson: {});

  FlEditorModel({required this.json});

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    // We have to give the editor wrapper all the necessary informations for the layout.
    super.applyFromJson(pJson);
    applyJsonToJson(pJson, json);

    var jsonColumnName = pJson[ApiObjectProperty.columnName];
    if (jsonColumnName != null) {
      columnName = jsonColumnName;
    }
    var jsonDataRow = pJson[ApiObjectProperty.dataRow];
    if (jsonDataRow != null) {
      dataRow = jsonDataRow;
    }
  }

  /// Applies component specific layout size information
  applyComponentInformation(FlComponentModel pComponentModel) {
    preferredSize ??= pComponentModel.preferredSize;
    minimumSize ??= pComponentModel.minimumSize;
    maximumSize ??= pComponentModel.maximumSize;
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
