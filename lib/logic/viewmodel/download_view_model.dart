import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/di/dependency_injection.dart';
import 'package:jvx_mobile_v3/model/download/download.dart';
import 'package:jvx_mobile_v3/services/network_service_response.dart';
import 'package:jvx_mobile_v3/services/real/real_download_service.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

class DownloadViewModel {
  String name;
  bool libraryImages;
  bool applicationImages;
  String clientId;
  NetworkServiceResponse apiResult;
  DownloadService downloadRepo = Injector().downloadService;

  DownloadViewModel({@required this.name, @required this.libraryImages, @required this.applicationImages, @required this.clientId});

  Future<Null> performDownload(DownloadViewModel downloadViewModel) async {
    NetworkServiceResponse<File> result = await downloadRepo.fetchDownloadResponse(Download(applicationImages: downloadViewModel.applicationImages, libraryImages: downloadViewModel.libraryImages, name: downloadViewModel.name, clientId: downloadViewModel.clientId));
    this.apiResult = result;
  }
}