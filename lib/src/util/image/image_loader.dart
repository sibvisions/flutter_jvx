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

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../flutter_ui.dart';
import '../../service/api/i_api_service.dart';
import '../../service/api/shared/repository/online_api_repository.dart';
import '../../service/apps/app.dart';
import '../../service/config/i_config_service.dart';
import '../../service/file/file_manager.dart';
import '../icon_util.dart';

abstract class ImageLoader {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  static const Widget DEFAULT_IMAGE = FaIcon(FontAwesomeIcons.circleQuestion, size: IconUtil.DEFAULT_ICON_SIZE);

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
      FlutterUI.logUI.e("Failed to load image $imageProvider", error: error, stackTrace: stackTrace);

      return ImageLoader.DEFAULT_IMAGE;
    };
  }

  /// Loads any server sent image string.
  static Widget loadImage(
    String imageDefinition, {
    Function(Size, bool)? imageStreamListener,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.none,
    AlignmentGeometry alignment = Alignment.center,
  }) {
    if (imageDefinition.isNotEmpty) {
      var iconDef = IconUtil.fromString(imageDefinition, width, color);

      if (iconDef?.icon != null) {

        imageStreamListener?.call(Size.square(iconDef?.size ?? IconUtil.DEFAULT_ICON_SIZE), true);

        return Align(
          alignment: alignment,
          child: iconDef!.icon,
        );
      }

      ImageProvider? imageProvider = getImageProvider(imageDefinition, imageStreamListener: imageStreamListener);

      if (imageProvider != null) {
        List<String> split = imageDefinition.split(",");

        double? width_;
        double? height_;

        if (split.length >= 3) {
          width_ = double.tryParse(split[1]);
          height_ = double.tryParse(split[2]);
        }

        return Image(
          image: imageProvider,
          loadingBuilder: createImageLoadingBuilder(),
          errorBuilder: createImageErrorBuilder(imageProvider),
          width: width_ ?? width,
          height: height_ ?? height,
          fit: fit,
          alignment: alignment,
        );
      }
    }

    imageStreamListener?.call(const Size.square(IconUtil.DEFAULT_ICON_SIZE), true);

    return DEFAULT_IMAGE;
  }

  static ImageProvider? getBinaryImageProvider(
      Uint8List bytes, {
      Function(Size, bool)? imageStreamListener,
  }) {
    ImageProvider imageProvider = MemoryImage(bytes);

    _addImageListener(imageProvider, imageStreamListener);

    return imageProvider;
  }

  /// Creates either a MemoryImage, a FileImage or a NetworkImage
  static ImageProvider? getImageProvider(
    String? imageDefinition, {
    App? app,
    Function(Size, bool)? imageStreamListener
  }) {
    if (imageDefinition == null || imageDefinition.isEmpty) {
      return null;
    }

    ImageProvider imageProvider;

    Uint8List? base64Decoded;

    if (isBase64(imageDefinition)) {
      try {
        base64Decoded = base64Decode(imageDefinition);
      } catch (ex) {
        FlutterUI.log.e(ex);
        //decode problem -
      }
    }

    double? width_;
    double? height_;

    if (base64Decoded != null) {
      imageProvider = MemoryImage(base64Decoded);
    }
    else {
      Uri? parsedURI;

      try {
        parsedURI = Uri.parse(imageDefinition);
      } catch (_) {}

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
    }

    if (width_ != null || height_ != null) {
      imageStreamListener?.call(Size(width_ ?? height_!, height_ ?? width_!), true);
    }
    else {
      _addImageListener(imageProvider, imageStreamListener);
    }

    return imageProvider;
  }

  static Map<String, String> _getHeaders() {
    Map<String, String> headers = {};
    var repository = IApiService().getRepository();

    if (repository is OnlineApiRepository) {
      if (repository.getCookies().isNotEmpty) {
        headers[HttpHeaders.cookieHeader] = repository.getCookies().map((e) => "${e.name}=${e.value}").join("; ");
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

  ///Checks whether the given [value] is base64 encoded
  static bool isBase64(dynamic value) {
    if (value.runtimeType == String) {
      final RegExp rx = RegExp(r'^([A-Za-z\d+/]{4})*([A-Za-z\d+/]{3}=|[A-Za-z\d+/]{2}==)?$',
        multiLine: true,
        unicode: true,
      );
      return rx.hasMatch(value);
    }
    return false;
  }

}
