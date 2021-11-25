import 'package:flutter_client/src/model/command/ui/update_components_command.dart';
import 'package:flutter_client/src/service/command/shared/processor/ui/update_components_processor.dart';

import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/ui/route_command.dart';
import '../../../../../model/command/ui/ui_command.dart';
import '../../i_command_processor.dart';
import 'route_command_processor.dart';

///
/// Process all sub-types of [UiCommand], delegates commands to specific sub [ICommandProcessor]
///
class UiProcessor implements ICommandProcessor<UiCommand> {

  final ICommandProcessor _routeCommandProcessor = RouteCommandProcessor();
  final ICommandProcessor _updateComponentsProcessor = UpdateComponentsProcessor();

  @override
  Future<List<BaseCommand>> processCommand(UiCommand command) async {
    //Switch-Case doesn't work for types
    if(command is RouteCommand){
      return _routeCommandProcessor.processCommand(command);
    } else if(command is UpdateComponentsCommand) {
      return _updateComponentsProcessor.processCommand(command);
    }


    return [];
  }

}