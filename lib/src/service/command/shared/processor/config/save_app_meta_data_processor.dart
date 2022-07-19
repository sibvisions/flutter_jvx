import 'dart:async';

import '../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/command/api/download_images_command.dart';
import '../../../../../model/command/api/download_style_command.dart';
import '../../../../../model/command/api/download_translation_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/config/save_app_meta_data_command.dart';
import '../../i_command_processor.dart';

class SaveAppMetaDataProcessor with ConfigServiceGetterMixin implements ICommandProcessor<SaveAppMetaDataCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SaveAppMetaDataCommand command) async {
    // Remove '.' to allow easy saving of images in filesystem
    String version = command.metaData.version.replaceAll(".", "_");

    getConfigService().setClientId(command.metaData.clientId);
    await getConfigService().setVersion(version);

    bool doLangExits = getConfigService().getFileManager().getDirectory(pPath: "languages/")?.existsSync() ?? false;
    bool doImgExits = getConfigService().getFileManager().getDirectory(pPath: "images/")?.existsSync() ?? false;

    List<BaseCommand> commands = [];
    if (!doLangExits) {
      commands.add(DownloadTranslationCommand(reason: "Translation should be downloaded"));
    }
    if (!doImgExits) {
      commands.add(DownloadImagesCommand(reason: "Resources should be downloaded"));
    }
    commands.add(DownloadStyleCommand(reason: "Styles should be downloaded"));
    return commands;
  }
}
