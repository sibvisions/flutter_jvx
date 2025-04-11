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

import '../../../../../model/command/config/config_command.dart';
import '../../../../../model/command/config/save_application_images_command.dart';
import '../../../../../model/command/config/save_application_meta_data_command.dart';
import '../../../../../model/command/config/save_application_parameters_command.dart';
import '../../../../../model/command/config/save_application_settings_command.dart';
import '../../../../../model/command/config/save_application_style_command.dart';
import '../../../../../model/command/config/save_application_templates_command.dart';
import '../../../../../model/command/config/save_application_translation_command.dart';
import '../../../../../model/command/config/save_auth_key_command.dart';
import '../../../../../model/command/config/save_download_command.dart';
import '../../../../../model/command/config/save_user_data_command.dart';
import '../../i_command_processor.dart';
import '../../i_command_processor_handler.dart';
import 'save_application_images_command_processor.dart';
import 'save_application_meta_data_command_processor.dart';
import 'save_application_parameters_command_processor.dart';
import 'save_application_settings_command_processor.dart';
import 'save_application_style_command_processor.dart';
import 'save_application_templates_command_processor.dart';
import 'save_application_translation_command_processor.dart';
import 'save_auth_key_command_processor.dart';
import 'save_or_show_file_command_processor.dart';
import 'save_user_data_command_processor.dart';

/// Handles the processors of [ConfigCommand].
class ConfigProcessor implements ICommandProcessorHandler<ConfigCommand> {
  final SaveApplicationMetaDataCommandProcessor _saveApplicationMetaDataProcessor =
      SaveApplicationMetaDataCommandProcessor();
  final SaveApplicationParametersCommandProcessor _saveApplicationParametersProcessor =
      SaveApplicationParametersCommandProcessor();
  final SaveApplicationSettingsCommandProcessor _saveApplicationSettingsProcessor =
      SaveApplicationSettingsCommandProcessor();
  final SaveUserDataCommandProcessor _saveUserDataCommandProcessor = SaveUserDataCommandProcessor();
  final SaveAuthKeyCommandProcessor _saveAuthKeyCommandProcessor = SaveAuthKeyCommandProcessor();
  final SaveApplicationImagesCommandProcessor _saveApplicationImagesCommandProcessor =
      SaveApplicationImagesCommandProcessor();
  final SaveApplicationTemplatesCommandProcessor _saveApplicationTemplatesCommandProcessor =
      SaveApplicationTemplatesCommandProcessor();
  final SaveApplicationTranslationCommandProcessor _saveApplicationTranslationCommandProcessor =
      SaveApplicationTranslationCommandProcessor();
  final SaveApplicationStyleCommandProcessor _applicationStyleCommandProcessor = SaveApplicationStyleCommandProcessor();
  final SaveOrShowFileCommandProcessor _saveDownloadCommandProcessor = SaveOrShowFileCommandProcessor();

  @override
  ICommandProcessor<ConfigCommand>? getProcessor(ConfigCommand command) {
    if (command is SaveApplicationMetaDataCommand) {
      return _saveApplicationMetaDataProcessor;
    } else if (command is SaveApplicationParametersCommand) {
      return _saveApplicationParametersProcessor;
    } else if (command is SaveApplicationSettingsCommand) {
      return _saveApplicationSettingsProcessor;
    } else if (command is SaveUserDataCommand) {
      return _saveUserDataCommandProcessor;
    } else if (command is SaveAuthKeyCommand) {
      return _saveAuthKeyCommandProcessor;
    } else if (command is SaveApplicationImagesCommand) {
      return _saveApplicationImagesCommandProcessor;
    } else if (command is SaveApplicationTemplatesCommand) {
      return _saveApplicationTemplatesCommandProcessor;
    } else if (command is SaveApplicationTranslationCommand) {
      return _saveApplicationTranslationCommandProcessor;
    } else if (command is SaveApplicationStyleCommand) {
      return _applicationStyleCommandProcessor;
    } else if (command is SaveOrShowFileCommand) {
      return _saveDownloadCommandProcessor;
    }

    return null;
  }
}
