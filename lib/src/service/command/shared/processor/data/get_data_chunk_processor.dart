import '../../../../../mixin/data_service_mixin.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/data/get_data_chunk_command.dart';
import '../../i_command_processor.dart';

class GetDataChunkProcessor with DataServiceMixin implements ICommandProcessor<GetDataChunkCommand> {
  @override
  Future<List<BaseCommand>> processCommand(GetDataChunkCommand command) async {
    return [];
  }
}
