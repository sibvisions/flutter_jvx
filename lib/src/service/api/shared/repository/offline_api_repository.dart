import 'dart:typed_data';

import 'package:flutter_client/src/model/api/requests/api_download_images_request.dart';
import 'package:flutter_client/src/model/api/requests/i_api_request.dart';
import 'package:flutter_client/src/model/api/response/api_response.dart';
import 'package:flutter_client/src/model/config/api/api_config.dart';
import 'package:flutter_client/src/service/api/shared/i_repository.dart';

class OfflineApiRepository implements IRepository {
  @override
  Future<Uint8List> downloadImages({required ApiDownloadImagesRequest pRequest}) {
    // TODO: implement downloadImages
    throw UnimplementedError();
  }

  @override
  Future<List<ApiResponse>> sendRequest({required IApiRequest pRequest}) {
    // TODO: implement sendRequest
    throw UnimplementedError();
  }

  @override
  void setApiConfig({required ApiConfig config}) {
    // TODO: implement setApiConfig
  }
}
