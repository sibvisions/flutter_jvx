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
import '../../../../../model/command/data/change_selected_row_command.dart';
import '../../../../../model/command/data/data_command.dart';
import '../../../../../model/command/data/delete_provider_data_command.dart';
import '../../../../../model/command/data/delete_row_command.dart';
import '../../../../../model/command/data/get_data_chunk_command.dart';
import '../../../../../model/command/data/get_meta_data_command.dart';
import '../../../../../model/command/data/get_selected_data_command.dart';
import '../../../../../model/command/data/save_fetch_data_command.dart';
import '../../../../../model/command/data/save_meta_data_command.dart';
import '../../i_command_processor.dart';
import 'change_selected_row_command_processor.dart';
import 'delete_provider_data_command_processor.dart';
import 'delete_row_command_processor.dart';
import 'get_data_chunk_command_processor.dart';
import 'get_meta_data_command_processor.dart';
import 'get_selected_data_command_processor.dart';
import 'save_fetch_data_command_processor.dart';
import 'save_meta_data_command_processor.dart';

/// Sends [DataCommand] to their respective processor
class DataProcessor extends ICommandProcessor<DataCommand> {
  /// Processes [SaveMetaDataCommand]
  final SaveMetaDataCommandProcessor _metaDataProcessor = SaveMetaDataCommandProcessor();

  /// Processes [SaveFetchDataCommand]
  final SaveFetchDataCommandProcessor _fetchDataProcessor = SaveFetchDataCommandProcessor();

  /// Processes [GetSelectedDataCommand]
  final GetSelectedDataCommandProcessor _getSelectedDataProcessor = GetSelectedDataCommandProcessor();

  /// Processes [GetDataChunkCommand]
  final GetDataChunkCommandProcessor _getDataChunkCommandProcessor = GetDataChunkCommandProcessor();

  /// Processes [DeleteProviderDataCommand]
  final DeleteProviderDataCommandProcessor _deleteProviderDataCommandProcessor = DeleteProviderDataCommandProcessor();

  final ChangeSelectedRowCommandProcessor _changeSelectedRowCommandProcessor = ChangeSelectedRowCommandProcessor();

  final DeleteRowCommandProcessor _deleteRowCommandProcessor = DeleteRowCommandProcessor();

  final GetMetaDataCommandProcessor _metaDataCommandProcessor = GetMetaDataCommandProcessor();

  @override
  Future<List<BaseCommand>> processCommand(DataCommand command) async {
    if (command is SaveMetaDataCommand) {
      return _metaDataProcessor.processCommand(command);
    } else if (command is SaveFetchDataCommand) {
      return _fetchDataProcessor.processCommand(command);
    } else if (command is GetSelectedDataCommand) {
      return _getSelectedDataProcessor.processCommand(command);
    } else if (command is GetDataChunkCommand) {
      return _getDataChunkCommandProcessor.processCommand(command);
    } else if (command is DeleteProviderDataCommand) {
      return _deleteProviderDataCommandProcessor.processCommand(command);
    } else if (command is ChangeSelectedRowCommand) {
      return _changeSelectedRowCommandProcessor.processCommand(command);
    } else if (command is GetMetaDataCommand) {
      return _metaDataCommandProcessor.processCommand(command);
    } else if (command is DeleteRowCommand) {
      return _deleteRowCommandProcessor.processCommand(command);
    }

    return [];
  }
}
