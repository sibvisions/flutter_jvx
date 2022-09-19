import 'package:archive/archive.dart';

import '../../../../../../services.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/config/save_application_translation_command.dart';
import '../../../../file/file_manager.dart';
import '../../i_command_processor.dart';

class SaveApplicationTranslationCommandProcessor implements ICommandProcessor<SaveApplicationTranslationCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SaveApplicationTranslationCommand command) async {
    IFileManager fileManager = IConfigService().getFileManager();
    List<Future> saveFutures = [];

    for (ArchiveFile translation in command.translations) {
      saveFutures.add(fileManager.saveFile(
          pContent: translation.content, pPath: "${IFileManager.LANGUAGES_PATH}/${translation.name}"));
    }

    // Wait till all files are saved
    await Future.wait(saveFutures);

    IConfigService().reloadSupportedLanguages();

    // Trigger load language
    IConfigService().loadLanguages();

    return [];
  }
}
