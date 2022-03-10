import 'package:flutter/foundation.dart';

import '../api_object_property.dart';

class DownloadImagesRequest {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Name of the request, will always be images
  final String name = "images";

  /// Session id of the client
  final String clientId;

  /// Set to true to download all images of the library
  final bool libraryImages = true;

  /// Set to true to download all images of the app
  final bool applicationImages = true;

  /// Send images as base64 encoded in web
  final String? contentMode = kIsWeb ? "base64" : null;


  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  DownloadImagesRequest({
    required this.clientId,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Map<String, dynamic> toJson() => {
    ApiObjectProperty.name : name,
    ApiObjectProperty.clientId : clientId,
    ApiObjectProperty.libraryImages : libraryImages,
    ApiObjectProperty.applicationImages : applicationImages,
    ApiObjectProperty.contentMode : contentMode
  };


}