import '../../../service/api/shared/api_object_property.dart';
import '../fl_component_model.dart';
import '../interface/i_data_model.dart';

class FlCustomContainerModel extends FlComponentModel implements IDataModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  @override
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
