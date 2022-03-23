import 'dart:typed_data';

import 'package:flutter_client/src/model/api/response/api_response.dart';

import '../../../model/command/base_command.dart';

abstract class IController {

  /// Process a list of [ApiResponse] into a list of [BaseCommand]s
  List<BaseCommand> processResponse({
    required List<ApiResponse> responses
  });

  /// Processes the download of the application images and saves them to disk.
  List<BaseCommand> processImageDownload({
    required Uint8List response,
    required String baseDir,
    required String appName,
    required String appVersion
  });
}
