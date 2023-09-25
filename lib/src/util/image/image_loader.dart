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
import '../../model/component/fl_component_model.dart';
import '../../service/api/i_api_service.dart';
import '../../service/api/shared/repository/online_api_repository.dart';
import '../../service/apps/app.dart';
import '../../service/config/i_config_service.dart';
import '../../service/file/file_manager.dart';
import '../font_awesome_util.dart';
import '../material_icons_util.dart';

abstract class ImageLoader {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  static const Widget DEFAULT_IMAGE = FaIcon(
    FontAwesomeIcons.circleQuestion,
    size: 16,
  );

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  static ImageLoadingBuilder createImageLoadingBuilder() {
    return (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
      if (loadingProgress == null) return child;
      return Center(
        child: CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null && loadingProgress.expectedTotalBytes! > 0
              ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes!)
              : null,
        ),
      );
    };
  }

  static ImageErrorWidgetBuilder createImageErrorBuilder(ImageProvider provider) {
    return (BuildContext context, Object error, StackTrace? stackTrace) {
      FlutterUI.logUI.e("Failed to load image $provider", error: error, stackTrace: stackTrace);
      return ImageLoader.DEFAULT_IMAGE;
    };
  }

  /// Loads any server sent image string.
  static Widget loadImage(
    String pImageString, {
    ImageProvider? imageProvider,
    Function(Size, bool)? pImageStreamListener,
    double? pWidth,
    double? pHeight,
    Color? pWantedColor,
    BoxFit pFit = BoxFit.none,
    AlignmentGeometry pAlignment = Alignment.center,
  }) {
    if (pImageString.isNotEmpty) {
      if (FontAwesomeUtil.checkFontAwesome(pImageString)) {
        FaIcon faIcon = FontAwesomeUtil.getFontAwesomeIcon(
          pText: pImageString,
          pIconSize: pWidth,
          pColor: pWantedColor,
        );
        pImageStreamListener?.call(Size.square(faIcon.size ?? FlIconModel.DEFAULT_ICON_SIZE), true);
        return faIcon;
      }
      if (MaterialIconUtil.checkMaterial(pImageString)) {
        Icon icon = MaterialIconUtil.getMaterialIcon(
          pText: pImageString,
          pIconSize: pWidth,
          pColor: pWantedColor,
        );
        pImageStreamListener?.call(Size.square(icon.size ?? FlIconModel.DEFAULT_ICON_SIZE), true);
        return icon;
      }

      imageProvider ??= ImageLoader.getImageProvider(pImageString, pImageStreamListener: pImageStreamListener);
      if (imageProvider != null) {
        List<String> split = pImageString.split(",");

        Size? size;
        if (split.length >= 3) {
          double? width = double.tryParse(split[1]);
          double? height = double.tryParse(split[2]);
          if (width != null && height != null) {
            size = Size(width, height);
          }
        }

        return Image(
          image: imageProvider,
          loadingBuilder: createImageLoadingBuilder(),
          errorBuilder: createImageErrorBuilder(imageProvider),
          width: size?.width ?? pWidth,
          height: size?.height ?? pHeight,
          color: pWantedColor,
          fit: pFit,
          alignment: pAlignment,
        );
      }
    }

    pImageStreamListener?.call(const Size.square(FlIconModel.DEFAULT_ICON_SIZE), true);
    return DEFAULT_IMAGE;
  }

  static ImageProvider? getBinaryImageProvider(
    Uint8List pBytes, {
    Function(Size, bool)? pImageStreamListener,
  }) {
    ImageProvider imageProvider = MemoryImage(pBytes);
    _addImageListener(imageProvider, pImageStreamListener);
    return imageProvider;
  }

  /// Creates either a MemoryImage, a FileImage or a NetworkImage
  static ImageProvider? getImageProvider(
    String? pImageString, {
    App? app,
    Function(Size, bool)? pImageStreamListener,
    bool pImageInBase64 = false,
  }) {
    if (pImageString == null || pImageString.isEmpty) {
      return null;
    }

    IFileManager fileManager = IConfigService().getFileManager();
    ImageProvider imageProvider;

    Uri? parsedURI;
    try {
      parsedURI = Uri.parse(pImageString);
    } catch (_) {}

    if (pImageInBase64) {
      imageProvider = MemoryImage(base64Decode(pImageString));
    } else {
      if (parsedURI == null || !parsedURI.scheme.contains("http")) {
        // Cut away optional size
        int commaIndex = pImageString.indexOf(",");
        if (commaIndex >= 0) {
          pImageString = pImageString.substring(0, commaIndex);
        }

        if (pImageString.startsWith("/")) {
          pImageString = pImageString.substring(1);
        }

        File? file;

        String effectiveAppId = app?.id ?? IConfigService().currentApp.value!;
        String? effectiveVersion = app?.version ?? IConfigService().version.value;

        if (effectiveVersion != null) {
          String path = fileManager.getAppSpecificPath(
            "${IFileManager.IMAGES_PATH}/$pImageString",
            appId: effectiveAppId,
            version: effectiveVersion,
          );
          file = fileManager.getFileSync(path);
        }

        if (file != null) {
          imageProvider = FileImage(file);
        } else {
          Uri effectiveBaseUrl = app?.baseUrl ?? IConfigService().baseUrl.value!;
          String effectiveAppName = app?.name ?? IConfigService().appName.value!;
          imageProvider =
              NetworkImage("$effectiveBaseUrl/resource/$effectiveAppName/$pImageString", headers: _getHeaders());
        }
      } else {
        imageProvider = NetworkImage(pImageString, headers: _getHeaders());
      }
    }

    _addImageListener(imageProvider, pImageStreamListener);

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
      imageProvider.resolve(const ImageConfiguration()).addListener(ImageLoader.createListener(imageStreamListener));
    }
  }

  static ImageStreamListener createListener(Function(Size, bool)? pImageStreamListener) {
    return ImageStreamListener((imageInfo, synchronousCall) {
      pImageStreamListener?.call(
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
}
