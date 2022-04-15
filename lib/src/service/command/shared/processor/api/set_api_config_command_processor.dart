import 'package:flutter_client/src/mixin/api_service_mixin.dart';
import 'package:flutter_client/src/model/command/api/set_api_config_command.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

class SetApiConfigCommandProcessor with ApiServiceMixin
    implements ICommandProcessor<SetApiConfigCommand> {

  @override
  Future<List<BaseCommand>> processCommand(SetApiConfigCommand command) async {

    apiService.setApiConfig(apiConfig: command.apiConfig);

    return [];
  }

}