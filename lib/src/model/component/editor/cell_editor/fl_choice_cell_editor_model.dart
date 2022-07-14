import 'dart:math';

import 'package:flutter/cupertino.dart';

import '../../../../../util/image/image_loader.dart';
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
      pConversion: (value) => ImageLoader.loadImage(value, pImageStreamListener: newMaxSize),
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
