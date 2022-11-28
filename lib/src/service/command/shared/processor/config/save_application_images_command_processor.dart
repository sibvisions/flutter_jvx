import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/config/save_application_images_command.dart';
import '../../../../config/i_config_service.dart';
import '../../../../file/file_manager.dart';
import '../../i_command_processor.dart';

class SaveApplicationImagesCommandProcessor implements ICommandProcessor<SaveApplicationImagesCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SaveApplicationImagesCommand command) async {
    IFileManager fileManager = IConfigService().getFileManager();

    Uint8List content;

    for (ArchiveFile file in command.images) {
      content = file.content;

      String name = file.name;
      if (file.name.startsWith("/")) {
        name.replaceFirst("/", "");
      }

      await fileManager.saveFile(pContent: content, pPath: "${IFileManager.IMAGES_PATH}/$name");
    }

    IConfigService().imagesChanged();

    return [];
  }
}
