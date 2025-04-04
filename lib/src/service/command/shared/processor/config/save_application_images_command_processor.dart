/*
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/config/save_application_images_command.dart';
import '../../../../config/i_config_service.dart';
import '../../../../file/file_manager.dart';
import '../../i_command_processor.dart';

class SaveApplicationImagesCommandProcessor extends ICommandProcessor<SaveApplicationImagesCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SaveApplicationImagesCommand command, BaseCommand? origin) async {
    IFileManager fileManager = IConfigService().getFileManager();

    Uint8List content;

    for (ArchiveFile file in command.images) {
      content = file.content;

      String name = file.name;
      if (file.name.startsWith("/")) {
        name.replaceFirst("/", "");
      }

      String path = fileManager.getAppSpecificPath("${IFileManager.IMAGES_PATH}/$name");
      await fileManager.saveFile(path, pContent: content);
    }

    IConfigService().imagesChanged();

    return [];
  }
}
