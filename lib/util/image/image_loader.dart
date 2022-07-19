import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../src/mixin/config_service_mixin.dart';
import '../file/file_manager.dart';
import '../font_awesome_util.dart';

class ImageLoader with ConfigServiceGetterMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  static const Widget DEFAULT_IMAGE = FaIcon(
    FontAwesomeIcons.questionCircle,
    size: 16,
  );

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ImageLoader();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Loads an Image from the filesystem.
  Image _loadImageFiles(
    String pPath, {
    double? pWidth,
    double? pHeight,
    Color? pBlendedColor,
    Function(Size, bool)? pImageStreamListener,
    bool imageInBinary = false,
    bool imageInBase64 = false,
    BoxFit fit = BoxFit.none,
  }) {
    String baseUrl = getConfigService().getApiConfig()!.urlConfig.getBasePath();
    String appName = getConfigService().getAppName();
    IFileManager fileManager = getConfigService().getFileManager();

    Image image;

    File? file = fileManager.getFileSync(pPath: pPath);

    if (imageInBinary) {
      Uint8List imageValues = imageInBase64 ? base64Decode(pPath) : Uint8List.fromList(pPath.codeUnits);
      image = Image.memory(
        imageValues,
        fit: fit,
        width: pWidth,
        height: pHeight,
        color: pBlendedColor,
      );
    } else if (file != null) {
      image = Image(
        fit: fit,
        image: FileImage(file),
        width: pWidth,
        height: pHeight,
        color: pBlendedColor,
        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                  : null,
            ),
          );
        },
      );
    } else {
      image = Image.network(
        '$baseUrl/resource/$appName/$pPath',
        fit: fit,
        width: pWidth,
        height: pHeight,
        color: pBlendedColor,
        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                  : null,
            ),
          );
        },
        errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
          return ImageLoader.DEFAULT_IMAGE;
        },
      );
    }

    if (pImageStreamListener != null) {
      image.image.resolve(const ImageConfiguration()).addListener(ImageLoader.createListener(pImageStreamListener));
    }

    return image;
  }

  /// Loads any server sent image string.
  static Widget loadImage(String pImageString,
      {Size? pWantedSize,
      Color? pWantedColor,
      Function(Size, bool)? pImageStreamListener,
      bool imageInBinary = false,
      bool imageInBase64 = true,
      BoxFit fit = BoxFit.none}) {
    if (pImageString.isEmpty) {
      try {
        return DEFAULT_IMAGE;
      } finally {
        pImageStreamListener?.call(const Size.square(16), true);
      }
    } else if (IFontAwesome.checkFontAwesome(pImageString)) {
      return IFontAwesome.getFontAwesomeIcon(pText: pImageString, pIconSize: pWantedSize?.width, pColor: pWantedColor);
    } else {
      String path = pImageString;
      Size? size;
      if (!imageInBinary) {
        List<String> arr = pImageString.split(',');

        path = arr[0];

        if (arr.length >= 3 && double.tryParse(arr[1]) != null && double.tryParse(arr[2]) != null) {
          size = Size(double.parse(arr[1]), double.parse(arr[2]));
        }

        if (pWantedSize != null) {
          size = pWantedSize;
        }
      }

      return ImageLoader()._loadImageFiles(
        path,
        pWidth: size?.width,
        pHeight: size?.height,
        pBlendedColor: pWantedColor,
        pImageStreamListener: pImageStreamListener,
        imageInBinary: imageInBinary,
        imageInBase64: imageInBase64,
        fit: fit,
      );
    }
  }

  static ImageStreamListener createListener(Function(Size, bool)? pImageStreamListener) {
    return ImageStreamListener((imageInfo, synchronousCall) {
      pImageStreamListener?.call(
        Size(
          imageInfo.image.width.toDouble(),
          imageInfo.image.height.toDouble(),
        ),
        synchronousCall,
      );
    });
  }
}
