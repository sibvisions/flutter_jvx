import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterclient/src/models/state/app_state.dart';
import 'package:flutterclient/src/util/download/download_helper.dart';

import '../../../injection_container.dart';
import 'image_loader.dart';

class ImageLoaderMobile implements ImageLoader {
  String? osName;
  String? osVersion;
  String? appVersion;
  String? deviceType;
  String? deviceTypeModel;
  String? technology;

  ImageLoaderMobile();

  Image loadImage(String path, [double? width, double? height]) {
    AppState appState = sl<AppState>();

    String localFilePath = DownloadHelper.getLocalFilePath(
        baseUrl: appState.serverConfig!.baseUrl,
        appName: appState.serverConfig!.appName,
        appVersion: appState.applicationMetaData?.version ?? '1.0',
        translation: false,
        baseDir: appState.baseDirectory);

    File file = File('$localFilePath$path');
    if (file.existsSync()) {
      return Image(
        image: FileImage(file),
        width: width,
        height: height,
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
              child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          (loadingProgress.expectedTotalBytes ?? 1)
                      : null));
        },
      );
    } else {
      return Image.network(
        '${appState.serverConfig!.baseUrl}/resource/${appState.serverConfig!.appName}$path',
        fit: BoxFit.contain,
        height: height,
        width: width,
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
              child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          (loadingProgress.expectedTotalBytes ?? 1)
                      : null));
        },
        errorBuilder:
            (BuildContext context, Object exception, StackTrace? stackTrace) {
          return Text('Couldn\'t load image with given url');
        },
      );
    }
  }
}

ImageLoader getImageLoader() => ImageLoaderMobile();
