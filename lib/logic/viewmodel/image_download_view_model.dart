import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/di/dependency_injection.dart';
import 'package:jvx_mobile_v3/model/download/download.dart';
import 'package:jvx_mobile_v3/services/network_service_response.dart';
import 'package:jvx_mobile_v3/services/real/real_download_service.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

class ImageDownloadViewModel {
  String name;
  bool libraryImages;
  bool applicationImages;
  String clientId;
  NetworkServiceResponse apiResult;
  ImageDownloadService imageDownloadRepo = Injector().downloadService;

  ImageDownloadViewModel({@required this.name, @required this.libraryImages, @required this.applicationImages, @required this.clientId});

  Future<Null> performImageDownload(ImageDownloadViewModel imageDownloadViewModel) async {
    NetworkServiceResponse<File> result = await imageDownloadRepo.fetchImageDownloadResponse(ImageDownload(applicationImages: true, libraryImages: true, name: 'images', clientId: globals.clientId));
    this.apiResult = result;
  }
}