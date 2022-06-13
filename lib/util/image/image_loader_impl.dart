import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_client/util/file/file_manager.dart';

import '../../src/mixin/config_service_mixin.dart';
import 'image_loader.dart';

ImageLoader getImageLoader() => ImageLoaderImpl();

class ImageLoaderImpl with ConfigServiceMixin implements ImageLoader {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  String? osName;
  String? osVersion;
  String? appVersion;
  String? deviceType;
  String? deviceTypeModel;
  String? technology;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ImageLoaderImpl();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Image loadImageFiles(
    String pPath, {
    double? pWidth,
    double? pHeight,
    Color? pBlendedColor,
    Function(Size, bool)? pImageStreamListener,
    bool imageInBinary = false,
  }) {
    String baseUrl = configService.getApiConfig().urlConfig.getBasePath();
    String appName = configService.getAppName();
    IFileManager fileManager = configService.getFileManager();

    Image image;

    File? file = fileManager.getFileSync(pPath: pPath);

    if (imageInBinary) {
      image = Image.memory(
        base64Decode(pPath),
        width: pWidth,
        height: pHeight,
        color: pBlendedColor,
      );
    } else if (file != null) {
      image = Image(
        fit: BoxFit.none,
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
                      : null));
        },
      );
    } else {
      image = Image.network(
        '$baseUrl/resource/$appName/$pPath',
        fit: BoxFit.none,
        width: pWidth,
        height: pHeight,
        color: pBlendedColor,
        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
              child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                      : null));
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
}
