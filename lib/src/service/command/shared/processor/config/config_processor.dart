import 'package:flutter_client/src/model/command/config/save_application_images_command.dart';
import 'package:flutter_client/src/model/command/config/save_application_style_command.dart';
import 'package:flutter_client/src/model/command/config/save_application_translation_command.dart';
import 'package:flutter_client/src/model/command/config/save_auth_key_command.dart';
import 'package:flutter_client/src/model/command/config/save_user_data_command.dart';
import 'package:flutter_client/src/service/command/shared/processor/config/save_application_images_command_processor.dart';
import 'package:flutter_client/src/service/command/shared/processor/config/save_application_translation_command_processor.dart';
import 'package:flutter_client/src/service/command/shared/processor/config/save_applicaton_style_command_processor.dart';
import 'package:flutter_client/src/service/command/shared/processor/config/save_auth_key_command_processor.dart';
import 'package:flutter_client/src/service/command/shared/processor/config/save_user_data_command_processor.dart';

import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/config/config_command.dart';
import '../../../../../model/command/config/save_app_meta_data_command.dart';
import '../../i_command_processor.dart';
import 'save_app_meta_data_processor.dart';

///
/// Processes [ConfigCommand], delegates them to their respective [ICommandProcessor]
///
class ConfigProcessor implements ICommandProcessor<ConfigCommand> {
  final SaveAppMetaDataProcessor _saveAppMetaDataProcessor = SaveAppMetaDataProcessor();

  final SaveUserDataCommandProcessor _saveUserDataCommandProcessor = SaveUserDataCommandProcessor();

  final SaveAuthKeyCommandProcessor _authKeyCommandProcessor = SaveAuthKeyCommandProcessor();

  final SaveApplicationImagesCommandProcessor _applicationImagesCommandProcessor = SaveApplicationImagesCommandProcessor();

  final SaveApplicationTranslationCommandProcessor _applicationTranslationCommandProcessor = SaveApplicationTranslationCommandProcessor();

  final SaveApplicationStyleCommandProcessor _applicationStyleCommandProcessor = SaveApplicationStyleCommandProcessor();

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
    }

    return [];
  }
}
