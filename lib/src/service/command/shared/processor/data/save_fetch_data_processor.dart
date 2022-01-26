import 'package:flutter_client/src/mixin/data_service_mixin.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/data/save_fetch_data_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

class SaveFetchDataProcessor with DataServiceMixin implements ICommandProcessor<SaveFetchDataCommand> {


  @override
  Future<List<BaseCommand>> processCommand(SaveFetchDataCommand command) async {

    dataService.updateData(pFetch: command.response);

    return [];
  }


}