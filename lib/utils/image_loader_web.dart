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

  Image loadImage(String path, [double width, double height]) {
    if (globals.files.containsKey(path))
      return Image.memory(base64Decode(globals.files[path]),
          height: height, width: width);

    return null;
  }
}

ImageLoader getImageLoader() => ImageLoaderWeb();
