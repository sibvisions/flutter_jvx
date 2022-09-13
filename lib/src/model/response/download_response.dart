import 'dart:typed_data';

import '../request/api_download_request.dart';
import 'api_response.dart';

/// Used when downloading application images archive
class DownloadResponse extends ApiResponse<ApiDownloadRequest> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Body of the response
  final Uint8List bodyBytes;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  DownloadResponse({
    required this.bodyBytes,
    required String name,
    required ApiDownloadRequest originalRequest,
  }) : super(name: name, originalRequest: originalRequest);
}
