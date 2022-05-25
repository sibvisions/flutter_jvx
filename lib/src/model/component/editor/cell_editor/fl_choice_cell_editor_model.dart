import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_client/util/image/image_loader.dart';

import '../../../api/api_object_property.dart';
import 'cell_editor_model.dart';

class FlChoiceCellEditorModel extends ICellEditorModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // The list of images to display.
  List<Widget> listImages = [];

  List<dynamic> listValues = [];

  Widget defaultImage = ImageLoader.DEFAULT_IMAGE;

  Size maxImageSize = const Size(14, 14);

  VoidCallback? imageLoadingCallback;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    // ContentType
    var jsonDefaultImageName = pJson[ApiObjectProperty.defaultImageName];
    if (jsonDefaultImageName != null) {
      defaultImage = ImageLoader.loadImage(
        jsonDefaultImageName,
        pImageStreamListener: newMaxSize,
      );
    }

    var jsonAllowedValues = pJson[ApiObjectProperty.allowedValues];
    if (jsonAllowedValues != null) {
      listValues = List<dynamic>.from(jsonAllowedValues);
    }

    var jsonImageNames = pJson[ApiObjectProperty.imageNames];
    if (jsonImageNames != null) {
      for (var jsonValueDynamic in jsonImageNames) {
        String jsonValue = jsonValueDynamic as String;

        listImages.add(
          ImageLoader.loadImage(
            jsonValue,
            pImageStreamListener: newMaxSize,
          ),
        );
      }
    }
  }

  void newMaxSize(Size pInfo, bool pSyncronous) {
    if (pInfo.width.toDouble() != maxImageSize.width || pInfo.height.toDouble() != maxImageSize.height) {
      maxImageSize = Size(
        max(
          pInfo.width.toDouble(),
          maxImageSize.width,
        ),
        max(
          pInfo.height.toDouble(),
          maxImageSize.height,
        ),
      );
      if (!pSyncronous) {
        imageLoadingCallback?.call();
      }
    }
  }
}
