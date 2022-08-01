import '../../../service/api/shared/api_object_property.dart';
import 'fl_button_model.dart';

/// The model for [FlToggleButtonWidget]
class FlToggleButtonModel extends FlButtonModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// If the button is selected;
  bool selected = false;

  /// If the button is selected (aria label)
  bool ariaPressed = false;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes the [FlButtonModel]
  FlToggleButtonModel() : super();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlToggleButtonModel get defaultModel => FlToggleButtonModel();

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    selected = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.selected,
      pDefault: defaultModel.selected,
      pCurrent: selected,
    );
    ariaPressed = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.ariaPressed,
      pDefault: defaultModel.ariaPressed,
      pCurrent: ariaPressed,
    );
  }
}
