import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/ui/route_command.dart';
import 'package:flutter_client/src/model/command/ui/ui_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';
import 'package:flutter_client/src/service/command/shared/processor/ui/route_command_processor.dart';

///
/// Process all sub-types of [UiCommand], delegates commands to specific sub [ICommandProcessor]
///
class UiProcessor implements ICommandProcessor<UiCommand> {

  final ICommandProcessor _routeCommandProcessor = RouteCommandProcessor();

  @override
  Future<List<BaseCommand>> processCommand(UiCommand command) async {
    //Switch-Case doesn't work for types
    if(command is RouteCommand){
      return _routeCommandProcessor.processCommand(command);
    }


    return [];
  }

}