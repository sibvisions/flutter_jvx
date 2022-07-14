import 'package:archive/archive.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/config/save_application_translation_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';
import 'package:flutter_client/util/file/file_manager.dart';

class SaveApplicationTranslationCommandProcessor with ConfigServiceMixin implements ICommandProcessor<SaveApplicationTranslationCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SaveApplicationTranslationCommand command) async {
    IFileManager fileManager = configService.getFileManager();
    List<Future> saveFutures = [];

    for (ArchiveFile translation in command.translations) {
      saveFutures.add(fileManager.saveFile(pContent: translation.content, pPath: "languages/${translation.name}"));
    }

    // Wait till all files are saved
    await Future.wait(saveFutures);

    configService.reloadSupportedLanguages();

    // Trigger load language
    configService.setLanguage(configService.getLanguage());

    return [];
  }
}
