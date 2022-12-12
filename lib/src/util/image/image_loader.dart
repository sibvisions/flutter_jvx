import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../flutter_ui.dart';
import '../../service/api/i_api_service.dart';
import '../../service/api/shared/repository/online_api_repository.dart';
import '../../service/config/i_config_service.dart';
import '../../service/file/file_manager.dart';
import '../font_awesome_util.dart';

//TODO investigate loading delays
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

  static ImageLoadingBuilder _createImageLoadingBuilder() {
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

  static ImageErrorWidgetBuilder _createImageErrorBuilder(ImageProvider provider) {
    return (BuildContext context, Object error, StackTrace? stackTrace) {
      FlutterUI.logUI.e("Failed to load image $provider", error, stackTrace);
      return ImageLoader.DEFAULT_IMAGE;
    };
  }

  /// Loads any server sent image string.
  static Widget loadImage(
    String pImageString, {
    required ImageProvider? imageProvider,
    Function(Size, bool)? pImageStreamListener,
    Size? pWantedSize,
    Color? pWantedColor,
    BoxFit pFit = BoxFit.none,
    AlignmentGeometry pAlignment = Alignment.center,
  }) {
    if (pImageString.isNotEmpty) {
      if (FontAwesomeUtil.checkFontAwesome(pImageString)) {
        FaIcon faIcon = FontAwesomeUtil.getFontAwesomeIcon(
          pText: pImageString,
          pIconSize: pWantedSize?.width,
          pColor: pWantedColor,
        );
        pImageStreamListener?.call(Size.square(faIcon.size!), true);
        return faIcon;
      } else if (imageProvider != null) {
        List<String> split = pImageString.split(",");

        Size? size;
        if (split.length >= 3) {
          double? width = double.tryParse(split[1]);
          double? height = double.tryParse(split[2]);
          if (width != null && height != null) {
            size = Size(width, height);
          }
        }

        size ??= pWantedSize;

        return Image(
          image: imageProvider,
          loadingBuilder: _createImageLoadingBuilder(),
          errorBuilder: _createImageErrorBuilder(imageProvider),
          width: size?.width,
          height: size?.height,
          color: pWantedColor,
          fit: pFit,
          alignment: pAlignment,
        );
      }
    }

    pImageStreamListener?.call(const Size.square(16), true);
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
    Function(Size, bool)? pImageStreamListener,
    bool pImageInBase64 = false,
  }) {
    if (pImageString == null || pImageString.isEmpty) {
      return null;
    }

    IFileManager fileManager = IConfigService().getFileManager();
    ImageProvider imageProvider;

    if (pImageInBase64) {
      imageProvider = MemoryImage(base64Decode(pImageString));
    } else {
      //Cut away optional size
      int commaIndex = pImageString.indexOf(",");
      if (commaIndex >= 0) {
        pImageString = pImageString.substring(0, commaIndex);
      }

      if (pImageString.startsWith("/")) {
        pImageString = pImageString.substring(1);
      }

      File? file = fileManager.getFileSync(pPath: "${IFileManager.IMAGES_PATH}/$pImageString");

      if (file != null) {
        imageProvider = FileImage(file);
      } else {
        String appName = IConfigService().getAppName()!;
        String baseUrl = IConfigService().getBaseUrl()!;

        Map<String, String> headers = {};
        var repository = IApiService().getRepository();
        if (repository is OnlineApiRepository) {
          headers.addAll(repository.getHeaders());
          if (repository.getCookies().isNotEmpty) {
            headers[HttpHeaders.cookieHeader] = repository.getCookies().map((e) => "${e.name}=${e.value}").join("; ");
          }
        }

        imageProvider = NetworkImage("$baseUrl/resource/$appName/$pImageString", headers: headers);
      }

      _addImageListener(imageProvider, pImageStreamListener);
    }
    return imageProvider;
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
