import 'dart:io';

import 'package:jvx_mobile_v3/model/download/download.dart';
import 'package:jvx_mobile_v3/services/abstract/i_download_service.dart';
import 'package:jvx_mobile_v3/services/network_service.dart';
import 'package:jvx_mobile_v3/services/network_service_response.dart';
import 'package:jvx_mobile_v3/services/restClient.dart';
import 'package:jvx_mobile_v3/utils/shared_preferences_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

class DownloadService extends NetworkService implements IDownloadSerivce {
  static const _kDownloadUrl = '/download';

  DownloadService(RestClient rest) : super(rest);

  @override
  Future<NetworkServiceResponse<File>> fetchDownloadResponse(Download download) async {
    if (download.name == 'images') {
      return await fetchImage(download);
    } else if (download.name == 'translation') {
      return await fetchTranslation(download);
    }
  }

  Future<NetworkServiceResponse<File>> fetchTranslation(Download download) async {
    var result = await rest.postAsyncDownload(_kDownloadUrl, download.toJson());

    var _dir = (await getApplicationDocumentsDirectory()).path;

    globals.dir = _dir;
            
    if (result.mappedResult != null) {
      var archive = result.mappedResult;

      globals.translation = Map<String, String>();

      for (var file in archive) {
        var filename = '$_dir/${file.name}';
        if (file.isFile) {
          var outFile = File(filename);
          print('TRANSLATION: ${globals.translation}');
          globals.translation[file.name] = filename;
          outFile = await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content);
        }
      }
      SharedPreferencesHelper().setTranslation(globals.translation);

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

  Future<NetworkServiceResponse<File>> fetchImage(Download download) async {
    var result = await rest.postAsyncDownload(_kDownloadUrl, download.toJson());

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