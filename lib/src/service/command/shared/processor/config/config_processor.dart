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

import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/config/config_command.dart';
import '../../../../../model/command/config/save_app_meta_data_command.dart';
import '../../../../../model/command/config/save_application_images_command.dart';
import '../../../../../model/command/config/save_application_style_command.dart';
import '../../../../../model/command/config/save_application_translation_command.dart';
import '../../../../../model/command/config/save_auth_key_command.dart';
import '../../../../../model/command/config/save_download_command.dart';
import '../../../../../model/command/config/save_user_data_command.dart';
import '../../i_command_processor.dart';
import 'save_app_meta_data_processor.dart';
import 'save_application_images_command_processor.dart';
import 'save_application_translation_command_processor.dart';
import 'save_applicaton_style_command_processor.dart';
import 'save_auth_key_command_processor.dart';
import 'save_download_processor.dart';
import 'save_user_data_command_processor.dart';

///
/// Processes [ConfigCommand], delegates them to their respective [ICommandProcessor]
///
class ConfigProcessor implements ICommandProcessor<ConfigCommand> {
  final SaveAppMetaDataCommandProcessor _saveAppMetaDataProcessor = SaveAppMetaDataCommandProcessor();

  final SaveUserDataCommandProcessor _saveUserDataCommandProcessor = SaveUserDataCommandProcessor();

  final SaveAuthKeyCommandProcessor _authKeyCommandProcessor = SaveAuthKeyCommandProcessor();

  final SaveApplicationImagesCommandProcessor _applicationImagesCommandProcessor =
      SaveApplicationImagesCommandProcessor();

  final SaveApplicationTranslationCommandProcessor _applicationTranslationCommandProcessor =
      SaveApplicationTranslationCommandProcessor();

  final SaveApplicationStyleCommandProcessor _applicationStyleCommandProcessor = SaveApplicationStyleCommandProcessor();

  final SaveDownloadCommandProcessor _saveDownloadCommandProcessor = SaveDownloadCommandProcessor();

  @override
  Future<List<BaseCommand>> processCommand(ConfigCommand command) async {
    if (command is SaveAppMetaDataCommand) {
      return _saveAppMetaDataProcessor.processCommand(command);
    } else if (command is SaveUserDataCommand) {
      return _saveUserDataCommandProcessor.processCommand(command);
    } else if (command is SaveAuthKeyCommand) {
      return _authKeyCommandProcessor.processCommand(command);
    } else if (command is SaveApplicationImagesCommand) {
      return _applicationImagesCommandProcessor.processCommand(command);
    } else if (command is SaveApplicationTranslationCommand) {
      return _applicationTranslationCommandProcessor.processCommand(command);
    } else if (command is SaveApplicationStyleCommand) {
      return _applicationStyleCommandProcessor.processCommand(command);
    } else if (command is SaveDownloadCommand) {
      return _saveDownloadCommandProcessor.processCommand(command);
    }

    return [];
  }
}
