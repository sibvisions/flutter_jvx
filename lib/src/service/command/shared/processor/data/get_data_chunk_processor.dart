import 'package:flutter_client/src/mixin/data_service_mixin.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/data/get_data_chunk_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

class GetDataChunkProcessor with DataServiceMixin implements ICommandProcessor<GetDataChunkCommand>{
  @override
  Future<List<BaseCommand>> processCommand(GetDataChunkCommand command) async {



    return [];
  }

}