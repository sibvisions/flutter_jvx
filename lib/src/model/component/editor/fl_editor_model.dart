import '../../../service/api/shared/api_object_property.dart';
import '../../../util/parse_util.dart';
import '../fl_component_model.dart';
import '../interface/i_data_model.dart';

class FlEditorModel extends FlComponentModel implements IDataModel {
  bool changedCellEditor = false;

  @override
  String dataProvider = "";

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

    dataProvider = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.dataRow,
      pDefault: defaultModel.dataProvider,
      pCurrent: dataProvider,
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
