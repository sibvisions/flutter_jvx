import 'package:http/http.dart';

import '../../../model/command/base_command.dart';

abstract class IController {

  Future<List<BaseCommand>> processResponse(Future<Response> response);

  /// Processes the download of the application images and saves them to disk.
  Future<List<BaseCommand>> processImageDownload({
    required Future<Response> response,
    required String baseDir,
    required String appName,
    required String appVersion
  });
}
