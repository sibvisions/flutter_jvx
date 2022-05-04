import 'package:flutter_client/src/model/command/data/get_data_chunk_command.dart';
import 'package:flutter_client/src/service/command/shared/processor/data/get_data_chunk_command_processor.dart';

import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/data/data_command.dart';
import '../../../../../model/command/data/get_selected_data.dart';
import '../../../../../model/command/data/save_fetch_data_command.dart';
import '../../../../../model/command/data/save_meta_data_command.dart';
import '../../i_command_processor.dart';
import 'get_selected_data_processor.dart';
import 'save_fetch_data_processor.dart';
import 'save_meta_data_processor.dart';

/// Sends [DataCommand] to their respective processor
class DataProcessor extends ICommandProcessor<DataCommand> {
  /// Processes [SaveMetaDataCommand]
  final SaveMetaDataProcessor _metaDataProcessor = SaveMetaDataProcessor();

  /// Processes [SaveFetchDataCommand]
  final SaveFetchDataProcessor _fetchDataProcessor = SaveFetchDataProcessor();

  /// Processes [GetSelectedDataCommand]
  final GetSelectedDataProcessor _getSelectedDataProcessor = GetSelectedDataProcessor();

  /// Processes [GetDataChunkCommand]
  final GetDataChunkCommandProcessor _getDataChunkCommandProcessor = GetDataChunkCommandProcessor();

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
    }

    return [];
  }
}
