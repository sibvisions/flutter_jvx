import 'dart:convert';
import 'dart:html';
import 'package:flutter/widgets.dart';
import 'image_loader.dart';
import 'globals.dart' as globals;

class ImageLoaderWeb implements ImageLoader {
  String osName;
  String osVersion;
  String appVersion;
  String deviceType;
  String deviceTypeModel;
  String technology;

  ImageLoaderWeb();

  Image loadImage(String path) {
    if (globals.files.containsKey(path))
      return Image.memory(base64Decode(globals.files[path]));

    return null;
  }
}

ImageLoader getImageLoader() => ImageLoaderWeb();
