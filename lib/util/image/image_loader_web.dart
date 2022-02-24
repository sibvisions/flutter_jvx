import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';
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
  Image loadImage(String path, [double? width, double? height]) {
    // TODO config loading
    bool isInMemory = path == configService.getAppName(); // appState.fileConfig.files.containsKey(path)
    String fileBinary = ""; //appState.fileConfig.files[path]!
    String baseUrl = ""; //appState.serverConfig!.baseUrl
    String appName = ""; //appState.serverConfig!.appName
    if (isInMemory) {
      return Image.memory(base64Decode(fileBinary), height: height, width: width);
    } else {
      return Image.network(
        '$baseUrl/resource/$appName$path',
        height: height,
        width: width,
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
