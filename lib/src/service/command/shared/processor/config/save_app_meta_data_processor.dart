import 'dart:async';

import '../../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/command/api/download_images_command.dart';
import '../../../../../model/command/api/download_style_command.dart';
import '../../../../../model/command/api/download_translation_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/config/save_app_meta_data_command.dart';
import '../../../../file/file_manager.dart';
import '../../i_command_processor.dart';

class SaveAppMetaDataCommandProcessor
    with ConfigServiceGetterMixin
    implements ICommandProcessor<SaveAppMetaDataCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SaveAppMetaDataCommand command) async {
    // Remove '.' to allow easy saving of images in filesystem
    String version = command.metaData.version.replaceAll(".", "_");

    getConfigService().setClientId(command.metaData.clientId);
    await getConfigService().setVersion(version);

    await getConfigService().setLanguage(command.metaData.langCode);

    getConfigService().setMetaData(command.metaData);

    bool doLangExits = getConfigService().getFileManager().getDirectory(pPath: "languages/")?.existsSync() ?? false;
    bool doImgExits =
        getConfigService().getFileManager().getDirectory(pPath: "${IFileManager.IMAGES_PATH}/")?.existsSync() ?? false;

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
