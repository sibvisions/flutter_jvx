import 'dart:convert';

import 'package:flutter_client/src/model/command/api/download_images_command.dart';
import 'package:flutter_client/src/model/command/api/download_translation_command.dart';
import 'package:flutter_client/src/model/config/config_file/last_run_config.dart';

import '../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/config/save_app_meta_data_command.dart';
import '../../i_command_processor.dart';

class SaveAppMetaDataProcessor with ConfigServiceMixin implements ICommandProcessor<SaveAppMetaDataCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SaveAppMetaDataCommand command) async {
    // Remove '.' to allow easy saving of images in filesystem
    String version = command.metaData.version.replaceAll(".", "_");

    configService.setClientId(command.metaData.clientId);
    configService.setVersion(version);

    LastRunConfig lastRunConfig = LastRunConfig(
      language: configService.getLanguage(),
      version: version,
    );

    configService.getFileManager().saveIndependentFile(
          pContent: jsonEncode(lastRunConfig).runes.toList(),
          pPath: "lastRunConfig.json",
        );

    bool doLangExits = configService.getFileManager().getDirectory(pPath: "languages/")?.existsSync() ?? false;
    bool doImgExits = configService.getFileManager().getDirectory(pPath: "images/")?.existsSync() ?? false;

    List<BaseCommand> commands = [];

    if (!doLangExits) {
      commands.add(DownloadTranslationCommand(reason: "Translation should be downloaded"));
    }
    if (!doImgExits) {
      commands.add(DownloadImagesCommand(reason: "Resources should be downloaded"));
    }
    return commands;
  }
}
