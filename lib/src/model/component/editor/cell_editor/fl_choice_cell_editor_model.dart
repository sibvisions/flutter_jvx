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
        pConversion: (value) => ImageLoader.loadImage(value, pImageStreamListener: newMaxSize));
    // var jsonDefaultImageName = pJson[ApiObjectProperty.defaultImageName];
    // if (pJson.containsKey(ApiObjectProperty.defaultImageName)) {
    //   if (jsonDefaultImageName == null) {
    //     defaultImage = defaultModel.defaultImage;
    //   }
    // }
    // if (jsonDefaultImageName != null) {
    //   defaultImage = ImageLoader.loadImage(
    //     jsonDefaultImageName,
    //     pImageStreamListener: newMaxSize,
    //   );
    // }

    listValues = getPropertyValue(
        pJson: pJson,
        pKey: ApiObjectProperty.allowedValues,
        pDefault: defaultModel.listValues,
        pCurrent: listValues,
        pConversion: (value) => List<dynamic>.from(value));

    // var jsonAllowedValues = pJson[ApiObjectProperty.allowedValues];
    // if (pJson.containsKey(ApiObjectProperty.defaultImageName)) {
    //   if (jsonAllowedValues == null) {
    //     listValues = defaultModel.listValues;
    //   }
    // }
    // if (jsonAllowedValues != null) {
    //   listValues = List<dynamic>.from(jsonAllowedValues);
    // }

    listImages = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.imageNames,
      pDefault: defaultModel.listImages,
      pCurrent: listImages,
      pConversion: _parseImgList,
    );

    // var jsonImageNames = pJson[ApiObjectProperty.imageNames];
    // if (pJson.containsKey(ApiObjectProperty.imageNames)) {
    //   if (jsonImageNames == null) {
    //     listImages = defaultModel.listImages;
    //   }
    // }
    // if (jsonImageNames != null) {
    //   for (var jsonValueDynamic in jsonImageNames) {
    //     String jsonValue = jsonValueDynamic as String;

    //     listImages.add(
    //       ImageLoader.loadImage(
    //         jsonValue,
    //         pImageStreamListener: newMaxSize,
    //       ),
    //     );
    //   }
    // }
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
          ),
        );
      }
    }
    return imageList;
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
