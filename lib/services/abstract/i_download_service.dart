import 'dart:io';

import 'package:jvx_mobile_v3/model/download/download.dart';
import 'package:jvx_mobile_v3/services/network_service_response.dart';

abstract class IDownloadSerivce {
  Future<NetworkServiceResponse<File>> fetchDownloadResponse(
    Download download
  );
}