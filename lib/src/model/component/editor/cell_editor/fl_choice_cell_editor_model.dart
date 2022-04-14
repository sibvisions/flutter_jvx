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

  List<String> listValues = [];

  Widget defaultImage = ImageLoader.DEFAULT_IMAGE;

  Size maxImageSize = const Size(14, 14);

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
        pImageStreamListener: ImageStreamListener((info, _) {
          maxImageSize = Size(max(info.image.width.toDouble(), maxImageSize.width),
              max(info.image.height.toDouble(), maxImageSize.height));
        }),
      );
    }

    var jsonAllowedValues = pJson[ApiObjectProperty.allowedValues];
    if (jsonAllowedValues != null) {
      for (var jsonValue in jsonAllowedValues) {
        listValues.add(jsonValue as String);
      }
    }

    var jsonImageNames = pJson[ApiObjectProperty.imageNames];
    if (jsonImageNames != null) {
      for (var jsonValueDynamic in jsonImageNames) {
        String jsonValue = jsonValueDynamic as String;

        listImages.add(
          ImageLoader.loadImage(
            jsonValue,
            pImageStreamListener: ImageStreamListener(
              (info, __) {
                maxImageSize = Size(max(info.image.width.toDouble(), maxImageSize.width),
                    max(info.image.height.toDouble(), maxImageSize.height));
              },
            ),
          ),
        );
      }
    }
  }
}
