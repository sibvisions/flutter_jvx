import '../../api/api_object_property.dart';
import '../fl_component_model.dart';

class FlCustomContainerModel extends FlComponentModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  String dataProvider = "";
  String columnName = "";
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlCustomContainerModel();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlCustomContainerModel get defaultModel => FlCustomContainerModel();

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    dataProvider = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.dataRow,
      pDefault: defaultModel.dataProvider,
      pCurrent: dataProvider,
    );

    columnName = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.columnName,
      pDefault: defaultModel.columnName,
      pCurrent: columnName,
    );
  }
}
