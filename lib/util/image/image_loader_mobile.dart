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

  @override
  Image loadImageFiles(String pPath, {double? pWidth, double? pHeight, Color? pBlendedColor}) {
    String baseUrl = configService.getUrl(); //appState.serverConfig!.baseUrl
    String appName = configService.getAppName(); //appState.serverConfig!.appName,
    String appVersion = configService.getVersion(); //appState.applicationMetaData?.version ?? 1.0
    String baseDir = configService.getDirectory(); //appState.baseDirectory

    String localFilePath =
        DownloadHelper.getLocalFilePath(appName: appName, appVersion: appVersion, translation: false, baseDir: baseDir);

    if (!pPath.startsWith('/')) {
      pPath = '/$pPath';
    }

    File file = File('$localFilePath$pPath');
    if (file.existsSync()) {
      return Image(
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
      return Image.network(
        '$baseUrl/resource/$appName$pPath',
        fit: BoxFit.contain,
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
          return const Text('Couldn\'t load image with given url');
        },
      );
    }
  }
}

ImageLoader getImageLoader() => ImageLoaderMobile();
