import 'package:flutter/cupertino.dart';
import 'package:flutter_client/src/model/component/fl_component_model.dart';

import '../../api/api_object_property.dart';

class FlIconModel extends FlComponentModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The image of the icon.
  String image = "";

  /// If the aspect ratio of the image should be preserved.
  bool preserveAspectRatio = true;

  /// Original size of the image.
  /// This is used to calculate the size of the image in the layout.
  Size originalSize = Size.zero;

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

      // Set the original size of the image.
      List<String> arr = jsonImage.split(',');

      if (arr.length >= 3 && double.tryParse(arr[1]) != null && double.tryParse(arr[2]) != null) {
        originalSize = Size(double.parse(arr[1]), double.parse(arr[2]));
      }
    }

    var jsonPreserveAspectRatio = pJson[ApiObjectProperty.preserveAspectRatio];
    if (jsonPreserveAspectRatio != null) {
      preserveAspectRatio = jsonPreserveAspectRatio;
    }
  }
}
