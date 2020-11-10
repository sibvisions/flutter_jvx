import 'dart:io';

import 'package:flutter/widgets.dart';

import '../../../injection_container.dart';
import '../../models/app/app_state.dart';
import 'image_loader.dart';

class ImageLoaderMobile implements ImageLoader {
  String osName;
  String osVersion;
  String appVersion;
  String deviceType;
  String deviceTypeModel;
  String technology;

  ImageLoaderMobile();

  Image loadImage(String path, [double width, double height]) {
    AppState appState = sl<AppState>();
    return Image.file(File('${appState.dir}$path'),
        width: width, height: height);
  }
}

ImageLoader getImageLoader() => ImageLoaderMobile();
