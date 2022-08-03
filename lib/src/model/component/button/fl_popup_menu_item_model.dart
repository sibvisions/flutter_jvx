import '../../../service/api/shared/api_object_property.dart';
import '../fl_component_model.dart';

/// The model for [FlPopupMenuWidget]
class FlPopupMenuItemModel extends FlComponentModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  String text = "";

  String? icon;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes the [FlPopupMenuItemModel]
  FlPopupMenuItemModel() : super();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlPopupMenuItemModel get defaultModel => FlPopupMenuItemModel();

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    text = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.text,
      pDefault: defaultModel.text,
      pCurrent: text,
    );

    icon = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.image,
      pDefault: defaultModel.icon,
      pCurrent: icon,
    );
  }
}
