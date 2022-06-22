import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/config/save_application_images_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';
import 'package:flutter_client/util/file/file_manager.dart';

class SaveApplicationImagesCommandProcessor with ConfigServiceMixin implements ICommandProcessor<SaveApplicationImagesCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SaveApplicationImagesCommand command) {
    IFileManager fileManager = configService.getFileManager();

    Uint8List content;

    for (ArchiveFile file in command.images) {
      content = file.content;

      String name = file.name;
      if (file.name.startsWith("/")) {
        name.replaceFirst("/", "");
      }

      fileManager.saveFile(pContent: content, pPath: "images/$name");
    }

    return SynchronousFuture([]);
  }
}
