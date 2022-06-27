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

    var jsondataProvider = pJson[ApiObjectProperty.dataRow];
    if (jsondataProvider != null) {
      dataProvider = jsondataProvider;
    }

    var jsonColumnName = pJson[ApiObjectProperty.columnName];
    if (jsonColumnName != null) {
      columnName = jsonColumnName;
    }
  }
}
