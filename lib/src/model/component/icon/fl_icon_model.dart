import 'package:flutter/widgets.dart';

import '../../../service/api/shared/api_object_property.dart';
import '../fl_component_model.dart';

class FlIconModel extends FlComponentModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The image of the icon.
  String image = "";

  /// If the aspect ratio of the image should be preserved.
  bool preserveAspectRatio = false;

  /// Original size of the image.
  /// This is used to calculate the size of the image in the layout.
  Size originalSize = const Size(16, 16);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes the [FlButtonModel]
  FlIconModel() : super() {
    minimumSize = const Size(16, 16);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlIconModel get defaultModel => FlIconModel();

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    _parseImage(pJson, defaultModel);

    preserveAspectRatio = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.preserveAspectRatio,
      pDefault: defaultModel.preserveAspectRatio,
      pCurrent: preserveAspectRatio,
    );
  }

  _parseImage(Map<String, dynamic> pJson, FlIconModel pDefaultModel) {
    if (pJson.containsKey(ApiObjectProperty.image)) {
      dynamic value = pJson[ApiObjectProperty.image];
      if (value != null) {
        // Set the original size of the image.
        List<String> arr = value.split(",");
        image = arr[0];

        if (arr.length >= 3) {
          double? width = double.tryParse(arr[1]);
          double? height = double.tryParse(arr[2]);
          if (width != null && height != null) {
            originalSize = Size(width, height);
          }
        }
      } else {
        image = pDefaultModel.image;
        originalSize = pDefaultModel.originalSize;
      }
    }
  }
}
