import 'dart:collection';

import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/data/data_command.dart';
import 'package:flutter_client/src/model/command/data/get_selected_data.dart';
import 'package:flutter_client/src/model/command/data/save_fetch_data_command.dart';
import 'package:flutter_client/src/model/command/data/save_meta_data_commnad.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';
import 'package:flutter_client/src/service/command/shared/processor/data/get_selected_data_processor.dart';
import 'package:flutter_client/src/service/command/shared/processor/data/save_fetch_data_processor.dart';
import 'package:flutter_client/src/service/command/shared/processor/data/save_meta_data_processor.dart';

/// Sends [DataCommand] to their respective processor
class DataProcessor extends ICommandProcessor<DataCommand>{

  /// Processes [SaveMetaDataCommand]
  final SaveMetaDataProcessor _metaDataProcessor = SaveMetaDataProcessor();
  /// Processes [SaveFetchDataCommand]
  final SaveFetchDataProcessor _fetchDataProcessor = SaveFetchDataProcessor();
  /// Processes [GetSelectedDataCommand]
  final GetSelectedDataProcessor _getSelectedDataProcessor = GetSelectedDataProcessor();


  @override
  Future<List<BaseCommand>> processCommand(DataCommand command) async {

    if(command is SaveMetaDataCommand){
      return _metaDataProcessor.processCommand(command);
    } else if(command is SaveFetchDataCommand){
      return _fetchDataProcessor.processCommand(command);
    } else if(command is GetSelectedDataCommand) {
      return _getSelectedDataProcessor.processCommand(command);
    }


    return [];

  }

}