/* 
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

part of 'package:flutter_jvx/src/model/component/fl_component_model.dart';

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

  @override
  Size? get minimumSize {
    if (_minimumSize != null) {
      return _minimumSize;
    }

    if (image.isNotEmpty) {
      return const Size.square(16);
    }
    return null;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes the [FlButtonModel]
  FlIconModel();

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
