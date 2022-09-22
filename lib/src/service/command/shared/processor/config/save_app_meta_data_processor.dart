import 'dart:async';

import '../../../../../../services.dart';
import '../../../../../model/command/api/download_images_command.dart';
import '../../../../../model/command/api/download_style_command.dart';
import '../../../../../model/command/api/download_translation_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/config/save_app_meta_data_command.dart';
import '../../../../api/shared/repository/online_api_repository.dart';
import '../../../../file/file_manager.dart';
import '../../i_command_processor.dart';

class SaveAppMetaDataCommandProcessor implements ICommandProcessor<SaveAppMetaDataCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SaveAppMetaDataCommand command) async {
    // Remove '.' to allow easy saving of images in filesystem
    String version = command.metaData.version.replaceAll(".", "_");

    IConfigService().setClientId(command.metaData.clientId);
    await IConfigService().setVersion(version);

    await IConfigService().setLanguage(command.metaData.langCode);

    IConfigService().setMetaData(command.metaData);

    bool doLangExits =
        IConfigService().getFileManager().getDirectory(pPath: "${IFileManager.LANGUAGES_PATH}/")?.existsSync() ?? false;
    bool doImgExits =
        IConfigService().getFileManager().getDirectory(pPath: "${IFileManager.IMAGES_PATH}/")?.existsSync() ?? false;

    await (IApiService().getRepository() as OnlineApiRepository?)?.startWebSocket();

    List<BaseCommand> commands = [];
    if (!doLangExits) {
      commands.add(DownloadTranslationCommand(reason: "Translation should be downloaded"));
    } else {
      IConfigService().reloadSupportedLanguages();
      IConfigService().loadLanguages();
    }
    if (!doImgExits) {
      commands.add(DownloadImagesCommand(reason: "Resources should be downloaded"));
    }
    commands.add(DownloadStyleCommand(reason: "Styles should be downloaded"));
    return commands;
  }
}
