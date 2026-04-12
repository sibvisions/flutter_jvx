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
  dynamic image;

  /// If the aspect ratio of the image should be preserved.
  bool preserveAspectRatio = false;

  /// Original size of the image.
  /// This is used to calculate the size of the image in the layout.
  Size originalSize = const Size.square(IconUtil.DEFAULT_ICON_SIZE);

  @override
  Size? get minimumSize {
    if (_minimumSize != null) {
      return _minimumSize;
    }

    if (!hasImage()) {
      return const Size.square(IconUtil.DEFAULT_ICON_SIZE);
    }
    return null;
  }

  bool hasImage() {
    return image != null && (image is! String || (image as String).isNotEmpty);
  }

  /// If image should be shown as avatar
  bool get showAsAvatar => styles.contains(FlImageCellEditorModel.STYLE_AS_AVATAR);

  /// If avatar should use available size not just the image size
  bool get showAvatarFullSize => styles.contains(FlImageCellEditorModel.STYLE_AVATAR_FULL_SIZE);

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
  void applyFromJson(Map<String, dynamic> newJson) {
    super.applyFromJson(newJson);

    _parseDefinition(newJson, defaultModel);

    preserveAspectRatio = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.preserveAspectRatio,
      defaultValue: defaultModel.preserveAspectRatio,
      currentValue: preserveAspectRatio,
    );
  }

  void _parseDefinition(Map<String, dynamic> json, FlIconModel defaultModel) {
    if (json.containsKey(ApiObjectProperty.image)) {
      dynamic value = json[ApiObjectProperty.image];
      if (value != null) {
        // Set the original size of the image.
        List<String> arr = value.split(",");
        image = value;

        if (arr.length >= 3) {
          double? width = double.tryParse(arr[1]);
          double? height = double.tryParse(arr[2]);

          originalSize = Size(width ?? originalSize.width, height ?? originalSize.height);
        }
      } else {
        image = defaultModel.image;
        originalSize = defaultModel.originalSize;
      }
    }
  }
}
