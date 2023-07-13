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

import '../../../../../model/command/storage/delete_screen_command.dart';
import '../../../../../model/command/storage/save_components_command.dart';
import '../../../../../model/command/storage/storage_command.dart';
import '../../i_command_processor.dart';
import '../../i_command_processor_handler.dart';
import 'delete_screen_command_processor.dart';
import 'save_components_commands_processor.dart';

/// Handles the processors of [StorageCommand].
class StorageProcessor implements ICommandProcessorHandler<StorageCommand> {
  final SaveComponentsCommandProcessor _saveComponentsProcessor = SaveComponentsCommandProcessor();
  final DeleteScreenCommandProcessor _deleteScreenProcessor = DeleteScreenCommandProcessor();

  @override
  ICommandProcessor<StorageCommand>? getProcessor(StorageCommand command) {
    if (command is SaveComponentsCommand) {
      return _saveComponentsProcessor;
    } else if (command is DeleteScreenCommand) {
      return _deleteScreenProcessor;
    }

    return null;
  }
}
