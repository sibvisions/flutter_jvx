import 'dart:async';

import '../../../../../model/command/api/alive_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_alive_request.dart';
import '../../../../api/i_api_service.dart';
import '../../i_command_processor.dart';

class AliveCommandProcessor implements ICommandProcessor<AliveCommand> {
  @override
  Future<List<BaseCommand>> processCommand(AliveCommand command) async {
    return IApiService().sendRequest(ApiAliveRequest());
  }
}
