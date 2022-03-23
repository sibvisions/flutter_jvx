import 'package:flutter/foundation.dart';
import 'package:flutter_client/src/model/api/requests/api_request.dart';

import '../api_object_property.dart';

/// Request to download all images the app needs
class ApiDownloadImagesRequest implements ApiRequest {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Session id
  final String clientId;
  /// Name of the request, will always be images
  final String name = "images";
  /// Set to true to download all images of the library
  final bool libraryImages = true;
  /// Set to true to download all images of the app
  final bool applicationImages = true;
  /// Send images as base64 encoded in web
  final String? contentMode = kIsWeb ? "base64" : null;
  /// Directory of the app
  final String baseDir;
  /// Images will be saved for this version
  final String appVersion;
  /// Images will be saved for this app
  final String appName;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiDownloadImagesRequest({
    required this.clientId,
    required this.baseDir,
    required this.appVersion,
    required this.appName
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Map<String, dynamic> toJson() => {
    ApiObjectProperty.name : name,
    ApiObjectProperty.clientId : clientId,
    ApiObjectProperty.libraryImages : libraryImages,
    ApiObjectProperty.applicationImages : applicationImages,
    ApiObjectProperty.contentMode : contentMode
  };


}