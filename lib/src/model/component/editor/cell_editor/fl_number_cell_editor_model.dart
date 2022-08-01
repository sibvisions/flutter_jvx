import '../../../../service/api/shared/api_object_property.dart';
import 'cell_editor_model.dart';

class FlNumberCellEditorModel extends ICellEditorModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  String numberFormat = "";

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  @override
  FlNumberCellEditorModel get defaultModel => FlNumberCellEditorModel();

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    numberFormat = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.numberFormat,
      pDefault: defaultModel.numberFormat,
      pCurrent: numberFormat,
    );
  }
}
