import 'dart:io';
import 'package:flutter/widgets.dart';
import 'image_loader.dart';
import 'globals.dart' as globals;

class ImageLoaderMobile implements ImageLoader {
  String osName;
  String osVersion;
  String appVersion;
  String deviceType;
  String deviceTypeModel;
  String technology;

  ImageLoaderMobile();

  Image loadImage(String path) {
    return Image.file(File('${globals.dir}$path'));
  }
}

ImageLoader getImageLoader() => ImageLoaderMobile();
