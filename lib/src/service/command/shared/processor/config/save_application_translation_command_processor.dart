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

import 'package:archive/archive.dart';

import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/config/save_application_translation_command.dart';
import '../../../../config/i_config_service.dart';
import '../../../../file/file_manager.dart';
import '../../../../ui/i_ui_service.dart';
import '../../i_command_processor.dart';

class SaveApplicationTranslationCommandProcessor implements ICommandProcessor<SaveApplicationTranslationCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SaveApplicationTranslationCommand command, BaseCommand? origin) async {
    IFileManager fileManager = IConfigService().getFileManager();
    List<Future> saveFutures = [];

    for (ArchiveFile translation in command.translations) {
      String path = fileManager.getAppSpecificPath("${IFileManager.LANGUAGES_PATH}/${translation.name}");
      saveFutures.add(fileManager.saveFile(path, pContent: translation.content));
    }

    // Wait till all files are saved
    await Future.wait(saveFutures);

    await IConfigService().reloadSupportedLanguages();
    // Trigger language load
    await IUiService().i18n().setLanguage(IConfigService().getLanguage());

    return [];
  }
}
