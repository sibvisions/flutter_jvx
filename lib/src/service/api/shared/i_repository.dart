import 'dart:typed_data';

import 'package:flutter_client/src/model/api/requests/api_download_images_request.dart';
import 'package:flutter_client/src/model/api/requests/i_api_request.dart';
import 'package:flutter_client/src/model/api/response/api_response.dart';

/// The interface declaring all possible requests to the mobile server.
abstract class IRepository {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Executes [pRequest],
  /// will throw an exception if request fails to be executed
  Future<List<ApiResponse>> sendRequest({required IApiRequest pRequest});

  /// Only used to download application images, since handling is completely
  /// different from normal requests
  Future<Uint8List> downloadImages({required ApiDownloadImagesRequest pRequest});
}
