import '../../../../commands.dart';
import 'fl_toggle_button_model.dart';

/// The model for [FlPopupMenuButtonWidget]
class FlPopupMenuButtonModel extends FlToggleButtonModel {
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
