import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterclient/src/models/state/app_state.dart';

import '../../../injection_container.dart';
import 'image_loader.dart';

class ImageLoaderWeb implements ImageLoader {
  String? osName;
  String? osVersion;
  String? appVersion;
  String? deviceType;
  String? deviceTypeModel;
  String? technology;

  ImageLoaderWeb();

  Image loadImage(String path, [double? width, double? height]) {
    AppState appState = sl<AppState>();
    if (appState.fileConfig.files.containsKey(path))
      return Image.memory(base64Decode(appState.fileConfig.files[path]!),
          height: height, width: width);
    else
      return Image.network(
        '${appState.serverConfig!.baseUrl}/resource/${appState.serverConfig!.appName}$path',
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

ImageLoader getImageLoader() => ImageLoaderWeb();
