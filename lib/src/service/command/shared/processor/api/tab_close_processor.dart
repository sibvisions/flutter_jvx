import 'package:flutter_client/src/mixin/api_service_mixin.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:flutter_client/src/model/command/api/tab_close_command.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

class TabCloseProcessor with ApiServiceMixin, ConfigServiceMixin implements ICommandProcessor<TabCloseCommand> {


  @override
  Future<List<BaseCommand>> processCommand(TabCloseCommand command) async {

    String? clientId = configService.getClientId();

    if(clientId != null){
      return apiService.closeTab(
          clientId: clientId,
          componentName: command.componentName,
          index: command.index
      );
    }

    return [];
  }

}