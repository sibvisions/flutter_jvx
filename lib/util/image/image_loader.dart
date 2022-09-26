import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../flutter_jvx.dart';
import '../../src/service/config/i_config_service.dart';
import '../../src/service/file/file_manager.dart';
import '../font_awesome_util.dart';

//TODO investigate loading delays
abstract class ImageLoader {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  static const Widget DEFAULT_IMAGE = FaIcon(
    FontAwesomeIcons.circleQuestion,
    size: 16,
  );

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Loads an Image from the filesystem.
  static Image _loadImageFiles({
    required String pPath,
    double? pWidth,
    double? pHeight,
    Color? pBlendedColor,
    Function(Size, bool)? pImageStreamListener,
    required bool pImageInBinary,
    required bool pImageInBase64,
    required BoxFit pFit,
    required AlignmentGeometry pAlignment,
  }) {
    String appName = IConfigService().getAppName()!;
    String baseUrl = IConfigService().getBaseUrl()!;
    IFileManager fileManager = IConfigService().getFileManager();

    Image image;

    File? file = fileManager.getFileSync(pPath: "${IFileManager.IMAGES_PATH}/$pPath");

    if (pImageInBinary) {
      Uint8List imageValues = pImageInBase64 ? base64Decode(pPath) : Uint8List.fromList(pPath.codeUnits);
      image = Image.memory(
        imageValues,
        alignment: pAlignment,
        fit: pFit,
        width: pWidth,
        height: pHeight,
        color: pBlendedColor,
      );
    } else if (file != null) {
      image = Image(
        image: FileImage(file),
        loadingBuilder: _getImageLoadingBuilder(),
        fit: pFit,
        alignment: pAlignment,
        width: pWidth,
        height: pHeight,
        color: pBlendedColor,
      );
    } else {
      image = Image.network(
        '$baseUrl/resource/$appName/$pPath',
        loadingBuilder: _getImageLoadingBuilder(),
        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
          FlutterJVx.log.e("Failed to load network image ($pPath)", error, stackTrace);
          return ImageLoader.DEFAULT_IMAGE;
        },
        fit: pFit,
        alignment: pAlignment,
        width: pWidth,
        height: pHeight,
        color: pBlendedColor,
      );
    }

    if (pImageStreamListener != null) {
      image.image.resolve(const ImageConfiguration()).addListener(ImageLoader.createListener(pImageStreamListener));
    }

    return image;
  }

  static ImageLoadingBuilder _getImageLoadingBuilder() {
    return (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
      if (loadingProgress == null) return child;
      return Center(
        child: CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null && loadingProgress.expectedTotalBytes! > 0
              ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes!)
              : null,
        ),
      );
    };
  }

  /// Loads any server sent image string.
  static Widget loadImage(String pImageString,
      {Size? pWantedSize,
      Color? pWantedColor,
      Function(Size, bool)? pImageStreamListener,
      bool pImageInBinary = false,
      bool pImageInBase64 = true,
      BoxFit pFit = BoxFit.none,
      AlignmentGeometry pAlignment = Alignment.center}) {
    if (pImageString.isEmpty) {
      try {
        return DEFAULT_IMAGE;
      } finally {
        pImageStreamListener?.call(const Size.square(16), true);
      }
    } else if (FontAwesomeUtil.checkFontAwesome(pImageString)) {
      return FontAwesomeUtil.getFontAwesomeIcon(
          pText: pImageString, pIconSize: pWantedSize?.width, pColor: pWantedColor);
    } else {
      String path = pImageString;
      Size? size;
      if (!pImageInBinary) {
        List<String> arr = pImageString.split(',');

        path = arr[0];

        if (arr.length >= 3 && double.tryParse(arr[1]) != null && double.tryParse(arr[2]) != null) {
          size = Size(double.parse(arr[1]), double.parse(arr[2]));
        }

        if (pWantedSize != null) {
          size = pWantedSize;
        }
      }

      return _loadImageFiles(
        pPath: path,
        pWidth: size?.width,
        pHeight: size?.height,
        pBlendedColor: pWantedColor,
        pImageStreamListener: pImageStreamListener,
        pImageInBinary: pImageInBinary,
        pImageInBase64: pImageInBase64,
        pFit: pFit,
        pAlignment: pAlignment,
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

  static String getPackageName() {
    return "flutter_jvx";
  }

  static String getAssetPath(bool inPackage, String path) {
    if (inPackage) {
      return 'packages/${getPackageName()}/$path';
    } else {
      return path;
    }
  }
}
