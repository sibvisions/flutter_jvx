/*
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:crypto/crypto.dart';

import '../../components/base_wrapper/base_comp_wrapper_widget.dart';
import '../../flutter_ui.dart';
import '../../service/api/i_api_service.dart';
import '../../service/apps/app.dart';
import '../../service/config/i_config_service.dart';
import '../../service/file/file_manager.dart';
import '../crypto_util.dart';
import '../icon_util.dart';
import '../jvx_logger.dart';

abstract class ImageLoader {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The default image if image loading fails
  static const Widget DEFAULT_IMAGE = FaIcon(FontAwesomeIcons.circleQuestion, size: IconUtil.DEFAULT_ICON_SIZE);

  /// The image cache
  static final Map<String, (MemoryImage image, Size? size)> _imageCache = {};

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // Private constructor to prevent instantiation
  ImageLoader._();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  static ImageLoadingBuilder createImageLoadingBuilder() {
    return (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
      if (loadingProgress == null) {
        return child;
      }
      else {
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null && loadingProgress.expectedTotalBytes! > 0
                ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes!)
                : null,
          ),
        );
      }
    };
  }

  static ImageErrorWidgetBuilder createImageErrorBuilder(ImageProvider imageProvider) {
    return (BuildContext context, Object error, StackTrace? stackTrace) {
      if (FlutterUI.logUI.cl(Lvl.e)) {
        FlutterUI.logUI.e("Failed to load image $imageProvider", error: error, stackTrace: stackTrace);
      }

      return ImageLoader.DEFAULT_IMAGE;
    };
  }

  /// Loads any server sent image string.
  static Widget loadImage(
    dynamic imageDefinition, {
    Function(Size, bool)? imageStreamListener,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.none,
    AlignmentGeometry alignment = Alignment.center,
    WidgetWrapper? wrapper,
    nowrap = false
  }) {
    ImageProvider? imageProvider;

    if (imageDefinition is Uint8List) {
      imageProvider = getBinaryImageProvider(imageDefinition, imageStreamListener: imageStreamListener);
    }
    else if (imageDefinition is String && imageDefinition.isNotEmpty) {
      var iconDef = IconUtil.fromString(imageDefinition, width, color);

      if (iconDef?.icon != null) {

        imageStreamListener?.call(Size.square(iconDef?.size ?? IconUtil.DEFAULT_ICON_SIZE), true);

        if (nowrap) {
          return iconDef!.icon!;
        }
        else {
          return Align(
            alignment: alignment,
            child: wrapper != null ? wrapper(iconDef!.icon, null) : iconDef!.icon,
          );
        }
      }

      imageProvider = getImageProvider(imageDefinition, imageStreamListener: imageStreamListener);
    }

    if (imageProvider != null) {
      double? width_;
      double? height_;

      if (imageDefinition is String && imageDefinition.isNotEmpty) {
        List<String> split = imageDefinition.split(",");

        if (split.length >= 3) {
          width_ = double.tryParse(split[1]);
          height_ = double.tryParse(split[2]);
        }
      }

      Image img = Image(
        image: imageProvider,
        loadingBuilder: createImageLoadingBuilder(),
        errorBuilder: createImageErrorBuilder(imageProvider),
        width: width_ ?? width,
        height: height_ ?? height,
        fit: fit,
        alignment: alignment,
        gaplessPlayback: imageProvider is MemoryImage,
      );

      if (wrapper != null) {
        return wrapper(img, null);
      }
      else {
        return img;
      }
    }

    imageStreamListener?.call(const Size.square(IconUtil.DEFAULT_ICON_SIZE), true);

    if (wrapper != null) {
      return wrapper(DEFAULT_IMAGE, null);
    }
    else {
      return DEFAULT_IMAGE;
    }
  }

  static ImageProvider getBinaryImageProvider(
      Uint8List bytes, {
      Function(Size, bool)? imageStreamListener,
  }) {
    ImageProvider imageProvider = MemoryImage(bytes);

    _addImageListener(imageProvider, imageStreamListener);

    return imageProvider;
  }

  static MemoryImage createCachedMemoryImage(String cacheKey, Uint8List data, Function(Size, bool)? imageStreamListener) {
    MemoryImage? memImage;

    (MemoryImage image, Size? size)? cacheInfo = _imageCache[cacheKey];

    double? width_;
    double? height_;

    if (cacheInfo != null) {
      memImage = cacheInfo.$1;

      Size? size = cacheInfo.$2;

      if (size != null) {
        width_ = size.width;
        height_ = size.height;
      }
    }

    if (memImage == null) {
      memImage = MemoryImage(data);

      var listener_ = imageStreamListener;

      //images < 500Kb will be cached
      if (data.lengthInBytes < 512000) {
        //we need a listener wrapper to update the cache with size
        listener_ = (Size size, bool synchronousCall) {
          _imageCache[cacheKey] = (memImage!, size);

          //foward to original listener
          if (imageStreamListener != null) {
            imageStreamListener(size, synchronousCall);
          }
        };

        _imageCache[cacheKey] = (memImage, null);
      }

      if (width_ != null || height_ != null) {
        listener_?.call(Size(width_ ?? height_!, height_ ?? width_!), true);
      }
      else {
        _addImageListener(memImage, listener_);
      }
    }

    return memImage;
  }

  /// Creates either a MemoryImage, a FileImage or a NetworkImage
  static ImageProvider? getImageProvider(
    dynamic imageDefinition, {
    App? app,
    Function(Size, bool)? imageStreamListener
  }) {
    if (imageDefinition == null) {
      return null;
    }

    if (imageDefinition is Uint8List) {
      return createCachedMemoryImage(md5.convert(imageDefinition).toString(), imageDefinition, imageStreamListener);
    }
    else if (imageDefinition is String && imageDefinition.isNotEmpty) {
      Uint8List? base64Decoded = CryptoUtil.tryDecodeBase64(imageDefinition);

      if (base64Decoded != null) {
        return createCachedMemoryImage(imageDefinition, base64Decoded, imageStreamListener);
      }
      else {
        Uri? parsedURI;

        try {
          parsedURI = Uri.parse(imageDefinition);
        } catch (_) {}

        ImageProvider imageProvider;

        double? width_;
        double? height_;

        if (parsedURI == null || !parsedURI.scheme.contains("http")) {
          // Cut away optional size
          int commaIndex = imageDefinition.indexOf(",");

          String imageDefinition_ = imageDefinition;
          if (commaIndex >= 0) {
            imageDefinition_ = imageDefinition.substring(0, commaIndex);

            List<String> split = imageDefinition.substring(commaIndex + 1).split(",");

            if (split.length >= 2) {
              width_ = double.tryParse(split[0]);
              height_ = double.tryParse(split[1]);
            }
          }

          if (imageDefinition_.startsWith("/")) {
            imageDefinition_ = imageDefinition_.substring(1);
          }

          File? file;

          String? appVersion = app?.version ?? IConfigService().version.value;

          if (appVersion != null) {
            IFileManager fileManager = IConfigService().getFileManager();

            String path = fileManager.getAppSpecificPath(
              "${IFileManager.IMAGES_PATH}/$imageDefinition_",
              appId: app?.id ?? IConfigService().currentApp.value!,
              version: appVersion,
            );

            file = fileManager.getFileSync(path);
          }

          if (file != null) {
            imageProvider = FileImage(file);
          } else {
            Uri baseUrl = app?.baseUrl ?? IConfigService().baseUrl.value!;
            String appName = app?.name ?? IConfigService().appName.value!;

            imageProvider = NetworkImage("$baseUrl/resource/$appName/$imageDefinition_", headers: _getHeaders());
          }
        } else {
          imageProvider = NetworkImage(imageDefinition, headers: _getHeaders());
        }

        if (width_ != null || height_ != null) {
          imageStreamListener?.call(Size(width_ ?? height_!, height_ ?? width_!), true);
        }
        else {
          _addImageListener(imageProvider, imageStreamListener);
        }

        return imageProvider;
      }
    }

    return null;
  }

  static Map<String, String> _getHeaders() {
    Map<String, String> headers = IApiService().getRepository().getHeaders();

    if (!kIsWeb) {
      Set<Cookie> cookies = IApiService().getRepository().getCookies();
      if (cookies.isNotEmpty) {
        String cookieNew = cookies.map((e) => "${e.name}=${e.value}").join("; ");

        String? cookieOld = headers[HttpHeaders.cookieHeader];
        if (cookieOld != null) {
          headers[HttpHeaders.cookieHeader] = "$cookieOld; $cookieNew}";
        }
        else {
          headers[HttpHeaders.cookieHeader] = cookieNew;
        }
      }
    }

    return headers;
  }

  static void _addImageListener(ImageProvider imageProvider, Function(Size, bool)? imageStreamListener) {
    if (imageStreamListener != null) {
      imageProvider.resolve(const ImageConfiguration()).addListener(ImageLoader._createListener(imageStreamListener));
    }
  }

  static ImageStreamListener _createListener(Function(Size, bool)? imageStreamListener) {
    return ImageStreamListener((imageInfo, synchronousCall) {
      imageStreamListener?.call(
        Size(
          imageInfo.image.width.toDouble(),
          imageInfo.image.height.toDouble(),
        ),
        synchronousCall,
      );
    });
  }

  static String getPackageName() {
    return "flutter_jvx";
  }

  static String getAssetPath(bool inPackage, String path) {
    if (inPackage) {
      return "packages/${getPackageName()}/$path";
    } else {
      return path;
    }
  }

  ///Clears the image cache
  static void clearCache() {
    _imageCache.clear();
  }

}
