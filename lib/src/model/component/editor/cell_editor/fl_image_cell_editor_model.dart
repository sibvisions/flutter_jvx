import '../../../../service/api/shared/api_object_property.dart';
import 'cell_editor_model.dart';

class FlImageCellEditorModel extends ICellEditorModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  String defaultImageName = "";

  /// If the aspect ratio of the image should be preserved.
  bool preserveAspectRatio = true;

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

    preserveAspectRatio = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.preserveAspectRatio,
      pDefault: defaultModel.preserveAspectRatio,
      pCurrent: preserveAspectRatio,
    );
  }
}
