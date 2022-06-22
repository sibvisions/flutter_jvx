import 'dart:typed_data';

import 'package:flutter_client/src/model/api/response/api_response.dart';

/// Used when downloading application images archive
class DownloadImagesResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Body of the response
  final Uint8List responseBody;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  DownloadImagesResponse({
    required this.responseBody,
    required String name,
    required Object originalRequest,
  }) : super(name: name, originalRequest: originalRequest);
}
