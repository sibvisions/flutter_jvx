import 'package:flutter_client/src/model/component/fl_component_model.dart';

import '../../api/api_object_property.dart';

class FlIconModel extends FlComponentModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The image of the icon.
  String image = "";

  /// If the aspect ratio of the image should be preserved.
  bool preserveAspectRatio = false;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes the [FlButtonModel]
  FlIconModel() : super();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    var jsonImage = pJson[ApiObjectProperty.image];
    if (jsonImage != null) {
      image = jsonImage;
    }

    var jsonPreserveAspectRatio = pJson[ApiObjectProperty.preserveAspectRatio];
    if (jsonPreserveAspectRatio != null) {
      preserveAspectRatio = jsonPreserveAspectRatio;
    }
  }
}
