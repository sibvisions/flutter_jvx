import 'package:flutter/material.dart';

class CustomImageCache extends WidgetsFlutterBinding {
  @override
  ImageCache createImageCache() {
    ImageCache imgCache = ImageCache();

    imgCache.maximumSize = 10;
    return imgCache;
  }
}
