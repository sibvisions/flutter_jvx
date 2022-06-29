import 'package:flutter_client/util/parse_util.dart';

import '../../api/api_object_property.dart';
import '../fl_component_model.dart';

class FlEditorModel extends FlComponentModel {
  bool changedCellEditor = false;

  String dataRow = "";

  String columnName = "";

  Map<String, dynamic> json = {};

  //ICellEditor cellEditor = FlDummyCellEditor(pCellEditorJson: {});

  FlEditorModel();

  @override
  FlEditorModel get defaultModel => FlEditorModel();

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    // We have to give the editor wrapper all the necessary informations for the layout.
    super.applyFromJson(pJson);
    ParseUtil.applyJsonToJson(pJson, json);

    columnName = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.columnName,
      pDefault: defaultModel.columnName,
      pCurrent: columnName,
    );

    dataRow = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.dataRow,
      pDefault: defaultModel.dataRow,
      pCurrent: dataRow,
    );

    changedCellEditor = pJson.keys.contains(ApiObjectProperty.cellEditor);
  }

  /// Applies component specific layout size information
  applyComponentInformation(FlComponentModel pComponentModel) {
    preferredSize ??= pComponentModel.preferredSize;
    minimumSize ??= pComponentModel.minimumSize;
    maximumSize ??= pComponentModel.maximumSize;
  }
}
