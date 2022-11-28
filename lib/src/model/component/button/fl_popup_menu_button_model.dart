import '../../../service/api/shared/api_object_property.dart';
import 'fl_button_model.dart';

/// The model for [FlPopupMenuButtonWidget]
class FlPopupMenuButtonModel extends FlButtonModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  String? defaultMenuItem;

  @override
  FlPopupMenuButtonModel get defaultModel => FlPopupMenuButtonModel();

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    defaultMenuItem = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.defaultMenuItem,
      pDefault: defaultModel.defaultMenuItem,
      pCurrent: defaultMenuItem,
    );
  }
}
