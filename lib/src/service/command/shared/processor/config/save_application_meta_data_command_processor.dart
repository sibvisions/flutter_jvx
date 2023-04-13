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

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../../../flutter_ui.dart';
import '../../../../../model/command/api/download_images_command.dart';
import '../../../../../model/command/api/download_style_command.dart';
import '../../../../../model/command/api/download_translation_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/config/save_application_meta_data_command.dart';
import '../../../../api/i_api_service.dart';
import '../../../../api/shared/repository/online_api_repository.dart';
import '../../../../apps/app_service.dart';
import '../../../../config/config_controller.dart';
import '../../../../file/file_manager.dart';
import '../../../../ui/i_ui_service.dart';
import '../../i_command_processor.dart';

class SaveApplicationMetaDataCommandProcessor implements ICommandProcessor<SaveApplicationMetaDataCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SaveApplicationMetaDataCommand command) async {
    // Remove '.' to allow easy saving of images in filesystem
    String version = command.metaData.version.replaceAll(".", "_");

    await AppService().removePreviousAppVersions(ConfigController().currentApp.value!, version);

    IUiService().updateClientId(command.metaData.clientId);
    await ConfigController().updateVersion(version);

    await ConfigController().updateApplicationLanguage(command.metaData.langCode);
    await ConfigController().updateApplicationTimeZone(command.metaData.timeZoneCode);

    IUiService().updateApplicationMetaData(command.metaData);

    String languagesPath = ConfigController().getFileManager().getAppSpecificPath("${IFileManager.LANGUAGES_PATH}/");
    String imagesPath = ConfigController().getFileManager().getAppSpecificPath("${IFileManager.IMAGES_PATH}/");
    Directory? languagesDir = ConfigController().getFileManager().getDirectory(languagesPath);
    Directory? imagesDir = ConfigController().getFileManager().getDirectory(imagesPath);

    // Start WebSocket
    unawaited((IApiService().getRepository() as OnlineApiRepository?)
        ?.startWebSocket()
        .catchError((e, stack) => FlutterUI.logAPI.w("Initial WebSocket connection failed", e, stack)));

    List<BaseCommand> commands = [];
    if (kDebugMode || !(languagesDir?.existsSync() ?? false)) {
      commands.add(DownloadTranslationCommand(reason: "Translation should be downloaded"));
    } else {
      ConfigController().reloadSupportedLanguages();
      ConfigController().loadLanguages();
    }
    if (!kIsWeb && (kDebugMode || !(imagesDir?.existsSync() ?? false))) {
      commands.add(DownloadImagesCommand(reason: "Resources should be downloaded"));
    }
    commands.add(DownloadStyleCommand(reason: "Styles should be downloaded"));
    return commands;
  }
}
