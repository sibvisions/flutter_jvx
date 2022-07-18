import '../../../api/api_object_property.dart';
import 'cell_editor_model.dart';

class FlImageCellEditorModel extends ICellEditorModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  String defaultImageName = "";

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  @override
  FlImageCellEditorModel get defaultModel => FlImageCellEditorModel();

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    defaultImageName = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.defaultImageName,
      pDefault: defaultModel.defaultImageName,
      pCurrent: defaultImageName,
    );
  }
}
