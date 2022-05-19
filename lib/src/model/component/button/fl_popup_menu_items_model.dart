import '../../api/api_object_property.dart';
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
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    var jsonText = pJson[ApiObjectProperty.text];
    if (jsonText != null) {
      text = jsonText;
    }

    var jsonIcon = pJson[ApiObjectProperty.image];
    if (jsonIcon != null) {
      icon = jsonIcon;
    }
  }
}
