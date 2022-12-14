/* Copyright 2022 SIB Visions GmbH
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

import 'dart:async';

import '../../../../../model/command/api/download_images_command.dart';
import '../../../../../model/command/api/download_style_command.dart';
import '../../../../../model/command/api/download_translation_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/config/save_app_meta_data_command.dart';
import '../../../../api/i_api_service.dart';
import '../../../../api/shared/repository/online_api_repository.dart';
import '../../../../config/config_service.dart';
import '../../../../file/file_manager.dart';
import '../../i_command_processor.dart';

class SaveAppMetaDataCommandProcessor implements ICommandProcessor<SaveAppMetaDataCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SaveAppMetaDataCommand command) async {
    // Remove '.' to allow easy saving of images in filesystem
    String version = command.metaData.version.replaceAll(".", "_");

    ConfigService().setClientId(command.metaData.clientId);
    await ConfigService().setVersion(version);

    ConfigService().setApplicationLanguage(command.metaData.langCode);
    await ConfigService().setApplicationTimeZone(command.metaData.timeZoneCode);

    ConfigService().setMetaData(command.metaData);

    bool doLangExits =
        ConfigService().getFileManager().getDirectory(pPath: "${IFileManager.LANGUAGES_PATH}/")?.existsSync() ?? false;
    bool doImgExits =
        ConfigService().getFileManager().getDirectory(pPath: "${IFileManager.IMAGES_PATH}/")?.existsSync() ?? false;

    await (IApiService().getRepository() as OnlineApiRepository?)?.startWebSocket();

    List<BaseCommand> commands = [];
    if (!doLangExits) {
      commands.add(DownloadTranslationCommand(reason: "Translation should be downloaded"));
    } else {
      ConfigService().reloadSupportedLanguages();
      ConfigService().loadLanguages();
    }
    if (!doImgExits) {
      commands.add(DownloadImagesCommand(reason: "Resources should be downloaded"));
    }
    commands.add(DownloadStyleCommand(reason: "Styles should be downloaded"));
    return commands;
  }
}
