import 'dart:convert';

import 'package:flutter/widgets.dart';

import '../../../injection_container.dart';
import '../../models/app/app_state.dart';
import 'image_loader.dart';

class ImageLoaderWeb implements ImageLoader {
  String osName;
  String osVersion;
  String appVersion;
  String deviceType;
  String deviceTypeModel;
  String technology;

  ImageLoaderWeb();

  Image loadImage(String path, [double width, double height]) {
    AppState appState = sl<AppState>();
    if (appState.files.containsKey(path))
      return Image.memory(base64Decode(appState.files[path]),
          height: height, width: width);

    return null;
  }
}

ImageLoader getImageLoader() => ImageLoaderWeb();
