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

class FlImageCellEditorModel extends ICellEditorModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The style if the image should be shown as avatar
  static const String STYLE_AS_AVATAR = "f_as_avatar";

  /// The style if the avatar should use full size instead of image size
  static const String STYLE_AVATAR_FULL_SIZE = "f_avatar_full_size";

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The name of the default image
  String defaultImageName = "";

  /// If the aspect ratio of the image should be preserved.
  bool preserveAspectRatio = true;

  /// If image should be shown as avatar
  bool get showAsAvatar => styles.contains(STYLE_AS_AVATAR);

  /// If avatar should use available size not just the image size
  bool get showAvatarFullSize => styles.contains(STYLE_AVATAR_FULL_SIZE);

  /// If image should show a standard border
  bool get hasStandardBorder => styles.contains(FlPanelModel.STYLE_STANDARD_BORDER);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  @override
  FlImageCellEditorModel get defaultModel => FlImageCellEditorModel();

  @override
  void applyFromJson(Map<String, dynamic> newJson) {
    super.applyFromJson(newJson);

    defaultImageName = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.defaultImageName,
      defaultValue: defaultModel.defaultImageName,
      currentValue: defaultImageName,
    );

    preserveAspectRatio = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.preserveAspectRatio,
      defaultValue: defaultModel.preserveAspectRatio,
      currentValue: preserveAspectRatio,
    );
  }
}
