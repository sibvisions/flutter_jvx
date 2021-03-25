import 'package:flutter/widgets.dart';
import 'image_loader_stub.dart'
    if (dart.library.io) 'image_loader_mobile.dart'
    if (dart.library.html) 'image_loader_web.dart';

abstract class ImageLoader {
  Image loadImage(String path, [double? width, double? height]);

  factory ImageLoader() => getImageLoader();
}
