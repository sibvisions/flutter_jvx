import '../../../components/label/fl_label_widget.dart';
import '../../layout/alignments.dart';

import '../../api/api_object_property.dart';
import '../fl_component_model.dart';

/// The model for [FlLabelWidget]
class FlLabelModel extends FlComponentModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The text shown in the [FlLabelWidget]
  String text = "";

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes the [FlLabelModel]
  FlLabelModel() : super() {
    horizontalAlignment = HorizontalAlignment.LEFT;
    verticalAlignment = VerticalAlignment.TOP;
  }

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
  }
}
