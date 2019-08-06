import 'dart:io';

import 'package:archive/archive.dart';
import 'package:jvx_mobile_v3/model/download/download.dart';
import 'package:jvx_mobile_v3/services/abstract/i_download_service.dart';
import 'package:jvx_mobile_v3/services/network_service.dart';
import 'package:jvx_mobile_v3/services/network_service_response.dart';
import 'package:jvx_mobile_v3/services/restClient.dart';
import 'package:path_provider/path_provider.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

class ImageDownloadService extends NetworkService implements IDownloadSerivce {
  static const _kImageDownloadUrl = '/download';

  ImageDownloadService(RestClient rest) : super(rest);

  @override
  Future<NetworkServiceResponse<File>> fetchImageDownloadResponse(ImageDownload imageDownload) async {
    var result = await rest.postAsyncImage(_kImageDownloadUrl, imageDownload.toJson());

    var _dir = (await getApplicationDocumentsDirectory()).path;

    globals.dir = _dir;
  
    if (result.mappedResult != null) {
      var archive = result.mappedResult;

      globals.images = List<String>();

      for (var file in archive) {
        var filename = '$_dir/${file.name}';
        if (file.isFile) {
          var outFile = File(filename);
          globals.images.add(filename);
          outFile = await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content);
        }
      }

      return new NetworkServiceResponse(
        content: File(''),
        success: result.networkServiceResponse.success
      );
    }
    return new NetworkServiceResponse(
      success: result.networkServiceResponse.success,
      message: result.networkServiceResponse.message
    );
  }
}