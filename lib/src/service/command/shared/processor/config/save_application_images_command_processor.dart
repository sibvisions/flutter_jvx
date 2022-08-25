import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/config/save_application_images_command.dart';
import '../../../../file/file_manager.dart';
import '../../i_command_processor.dart';

class SaveApplicationImagesCommandProcessor
    with ConfigServiceGetterMixin
    implements ICommandProcessor<SaveApplicationImagesCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SaveApplicationImagesCommand command) {
    IFileManager fileManager = getConfigService().getFileManager();

    Uint8List content;

    for (ArchiveFile file in command.images) {
      content = file.content;

      String name = file.name;
      if (file.name.startsWith("/")) {
        name.replaceFirst("/", "");
      }

      fileManager.saveFile(pContent: content, pPath: IFileManager.IMAGES_PATH + "/$name");
    }

    return Future.value([]);
  }
}
