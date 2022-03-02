import 'dart:io';

import 'package:flutter/material.dart';
import '../../src/mixin/config_service_mixin.dart';
import '../download/download_helper.dart';
import 'image_loader.dart';

class ImageLoaderMobile with ConfigServiceMixin implements ImageLoader {
  String? osName;
  String? osVersion;
  String? appVersion;
  String? deviceType;
  String? deviceTypeModel;
  String? technology;

  ImageLoaderMobile();

  Image loadImage(String path, [double? width, double? height]) {
    // TODO config loading

    String baseUrl = ""; //appState.serverConfig!.baseUrl
    String appName = ""; //appState.serverConfig!.appName,
    String appVersion = "1.0"; //appState.applicationMetaData?.version ?? 1.0
    String baseDir = ""; //appState.baseDirectory

    String localFilePath = DownloadHelper.getLocalFilePath(
        baseUrl: baseUrl, appName: appName, appVersion: appVersion, translation: false, baseDir: baseDir);

    File file = File('$localFilePath$path');
    if (file.existsSync()) {
      return Image(
        image: FileImage(file),
        width: width,
        height: height,
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
      return Image.network(
        '$baseUrl/resource/$appName$path',
        fit: BoxFit.contain,
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

ImageLoader getImageLoader() => ImageLoaderMobile();
