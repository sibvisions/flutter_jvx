import '../../../components/button/fl_toggle_button_widget.dart';
import 'fl_button_model.dart';

import '../../api/api_object_property.dart';

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
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    var jsonSelected = pJson[ApiObjectProperty.selected];
    if (jsonSelected != null) {
      selected = jsonSelected;
    }

    var jsonAriaPressed = pJson[ApiObjectProperty.ariaPressed];
    if (jsonAriaPressed != null) {
      ariaPressed = jsonAriaPressed;
    }
  }
}
