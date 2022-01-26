import 'dart:developer';

import 'package:flutter_client/src/mixin/data_service_mixin.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/data/save_meta_data_commnad.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

class SaveMetaDataProcessor with DataServiceMixin implements ICommandProcessor<SaveMetaDataCommand>{

  @override
  Future<List<BaseCommand>> processCommand(SaveMetaDataCommand command) async {

    dataService.updateMetaData(pMetaData: command.response);

    return [];
  }

}