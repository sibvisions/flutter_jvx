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
import '../../../../../model/command/api/download_templates_command.dart';
import '../../../../../model/command/api/download_translation_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/config/save_application_meta_data_command.dart';
import '../../../../api/i_api_service.dart';
import '../../../../api/shared/repository/online_api_repository.dart';
import '../../../../apps/i_app_service.dart';
import '../../../../config/i_config_service.dart';
import '../../../../file/file_manager.dart';
import '../../../../ui/i_ui_service.dart';
import '../../i_command_processor.dart';

class SaveApplicationMetaDataCommandProcessor extends ICommandProcessor<SaveApplicationMetaDataCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SaveApplicationMetaDataCommand command, BaseCommand? origin) async {
    // Remove '.' to allow easy saving of images in filesystem
    String version = command.metaData.version.replaceAll(".", "_");

    IApiService servApi = IApiService();
    IConfigService servConf = IConfigService();

    await IAppService().removePreviousAppVersions(servConf.currentApp.value!, version);

    IUiService servUi = IUiService();

    await servConf.updateVersion(version);
    await servConf.updateApplicationTimeZone(command.metaData.timeZoneCode);
    await servConf.updateCustomLanguage(command.metaData.customLanguage);
    await servConf.updateApplicationLanguage(command.metaData.langCode);

    //update clientid after language to avoid warnings because language will be downloaded in next step
    //and is not available in web environment right now
    servUi.updateClientId(command.metaData.clientId);

    servUi.updateApplicationMetaData(command.metaData);

    IFileManager fileManager = servConf.getFileManager();

    String languagesPath = fileManager.getAppSpecificPath("${IFileManager.LANGUAGES_PATH}/");
    String imagesPath = fileManager.getAppSpecificPath("${IFileManager.IMAGES_PATH}/");
    String templatesPath = fileManager.getAppSpecificPath("${IFileManager.TEMPLATES_PATH}/");

    Directory? languagesDir = fileManager.getDirectory(languagesPath);
    Directory? imagesDir = fileManager.getDirectory(imagesPath);
    Directory? templatesDir = fileManager.getDirectory(templatesPath);

    // Start WebSocket
    unawaited((servApi.getRepository() as OnlineApiRepository?)?.startWebSocket().catchError(
        (e, stack) => FlutterUI.logAPI.w("Initial WebSocket connection failed", error: e, stackTrace: stack)));

    List<BaseCommand> commands = [];

    if (kDebugMode || !(languagesDir?.existsSync() ?? false)) {
      commands.add(DownloadTranslationCommand(reason: "Translation should be downloaded"));
    } else {
      await servConf.reloadSupportedLanguages();
      await servUi.i18n().setLanguage(servConf.getLanguage());
    }

    if (!kIsWeb && (kDebugMode || !(imagesDir?.existsSync() ?? false))) {
      commands.add(DownloadImagesCommand(reason: "Images should be downloaded"));
    }

    if (!kIsWeb && (kDebugMode || !(templatesDir?.existsSync() ?? false))) {
      commands.add(DownloadTemplatesCommand(reason: "Templates should be downloaded"));
    }

    commands.add(DownloadStyleCommand(reason: "Styles should be downloaded"));
    return commands;
  }
}
