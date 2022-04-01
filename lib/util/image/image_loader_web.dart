import 'dart:convert';

import 'package:flutter/material.dart';

import '../../src/mixin/config_service_mixin.dart';
import 'image_loader.dart';

class ImageLoaderWeb with ConfigServiceMixin implements ImageLoader {
  String? osName;
  String? osVersion;
  String? appVersion;
  String? deviceType;
  String? deviceTypeModel;
  String? technology;

  ImageLoaderWeb();

  @override
  Image loadImageFiles(String pPath, {double? pWidth, double? pHeight, Color? pBlendedColor}) {
    // TODO config loading
    bool isInMemory = pPath == configService.getAppName(); // appState.fileConfig.files.containsKey(path)
    String fileBinary = ""; //appState.fileConfig.files[path]!
    String baseUrl = configService.getUrl(); //appState.serverConfig!.baseUrl
    String appName = configService.getAppName(); //appState.serverConfig!.appName

    if (isInMemory) {
      return Image.memory(
        base64Decode(fileBinary),
        height: pHeight,
        width: pWidth,
        color: pBlendedColor,
      );
    } else {
      return Image.network(
        '$baseUrl/resource/$appName$pPath',
        height: pHeight,
        width: pWidth,
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
          return const Text('Couldn\'t load image with given url');
        },
      );
    }
  }
}

ImageLoader getImageLoader() => ImageLoaderWeb();
