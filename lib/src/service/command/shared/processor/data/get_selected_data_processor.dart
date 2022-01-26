import 'package:flutter_client/src/mixin/data_service_mixin.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/data/get_selected_data.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

class GetSelectedDataProcessor with DataServiceMixin implements ICommandProcessor<GetSelectedDataCommand>
{

  @override
  Future<List<BaseCommand>> processCommand(GetSelectedDataCommand command) async {



    return [];
  }
}