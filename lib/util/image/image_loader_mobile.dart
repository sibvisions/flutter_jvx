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
  Image loadImageFiles(String pPath,
      {double? pWidth, double? pHeight, Color? pBlendedColor, ImageStreamListener? pImageStreamListener}) {
    String baseUrl = configService.getApiConfig().urlConfig.getBasePath(); //appState.serverConfig!.baseUrl
    String appName = configService.getAppName(); //appState.serverConfig!.appName,
    String appVersion = configService.getVersion(); //appState.applicationMetaData?.version ?? 1.0
    String baseDir = configService.getDirectory(); //appState.baseDirectory

    String localFilePath =
        DownloadHelper.getLocalFilePath(appName: appName, appVersion: appVersion, translation: false, baseDir: baseDir);

    if (!pPath.startsWith('/')) {
      pPath = '/$pPath';
    }

    Image image;

    File file = File('$localFilePath$pPath');
    if (file.existsSync()) {
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
        '$baseUrl/resource/$appName$pPath',
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
      image.image.resolve(const ImageConfiguration()).addListener(pImageStreamListener);
    }

    return image;
  }
}

ImageLoader getImageLoader() => ImageLoaderMobile();
