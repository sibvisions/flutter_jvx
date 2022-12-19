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

import 'dart:math';

import 'package:flutter/widgets.dart';

import '../../../../service/api/shared/api_object_property.dart';
import '../../../../util/image/image_loader.dart';
import 'cell_editor_model.dart';

class FlChoiceCellEditorModel extends ICellEditorModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // The list of images to display.
  List<Widget> listImages = [];

  List<dynamic> listValues = [];

  Widget defaultImage = ImageLoader.DEFAULT_IMAGE;

  double imageSize = 32;

  VoidCallback? imageLoadingCallback;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  @override
  FlChoiceCellEditorModel get defaultModel => FlChoiceCellEditorModel();

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    // ContentType
    defaultImage = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.defaultImageName,
      pDefault: defaultModel.defaultImage,
      pCurrent: defaultImage,
      pConversion: (value) => ImageLoader.loadImage(
        value,
        pImageStreamListener: newMaxSize,
        imageProvider: ImageLoader.getImageProvider(
          value,
          pImageStreamListener: newMaxSize,
        ),
      ),
    );

    listValues = getPropertyValue(
        pJson: pJson,
        pKey: ApiObjectProperty.allowedValues,
        pDefault: defaultModel.listValues,
        pCurrent: listValues,
        pConversion: (value) => List<dynamic>.from(value));

    listImages = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.imageNames,
      pDefault: defaultModel.listImages,
      pCurrent: listImages,
      pConversion: _parseImgList,
    );
  }

  List<Widget>? _parseImgList(dynamic pValue) {
    List<Widget> imageList = [];
    if (pValue != null) {
      for (var jsonValueDynamic in pValue) {
        String jsonValue = jsonValueDynamic as String;

        imageList.add(
          ImageLoader.loadImage(
            jsonValue,
            pImageStreamListener: newMaxSize,
            imageProvider: ImageLoader.getImageProvider(
              jsonValue,
              pImageStreamListener: newMaxSize,
            ),
          ),
        );
      }
    }
    return imageList;
  }

  void newMaxSize(Size pInfo, bool pSynchronous) {
    if (pInfo.width.toDouble() > imageSize || pInfo.height.toDouble() > imageSize) {
      imageSize = max(
        max(
          pInfo.width.toDouble(),
          pInfo.height.toDouble(),
        ),
        imageSize,
      );
      if (!pSynchronous) {
        imageLoadingCallback?.call();
      }
    }
  }
}
