import 'dart:io';

import 'package:flutter_client/src/mixin/api_service_mixin.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:flutter_client/src/model/command/api/download_images_command.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';
import 'package:path_provider/path_provider.dart';

class DownloadImagesProcessor with ApiServiceMixin, ConfigServiceMixin implements ICommandProcessor<DownloadImagesCommand> {


  @override
  Future<List<BaseCommand>> processCommand(DownloadImagesCommand command) async {

    Directory directory = await getApplicationDocumentsDirectory();

    configService.setDirectory(directory.path);
    String? clientId = configService.getClientId();
    String baseDir = configService.getDirectory();
    String appVersion = configService.getVersion();
    String appName = configService.getAppName();

    if(clientId != null) {
      apiService.downloadImages(
        baseDir: baseDir,
        clientId: clientId,
        appName: appName,
        appVersion: appVersion
      );
    }

    return [];
  }
}