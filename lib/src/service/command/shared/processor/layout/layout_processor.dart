import 'package:flutter_client/src/model/command/layout/register_parent_command.dart';
import 'package:flutter_client/src/service/command/shared/processor/layout/register_parent_processor.dart';

import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/layout/preferred_size_command.dart';
import '../../i_command_processor.dart';
import 'preferred_size_processort.dart';

class LayoutProcessor implements ICommandProcessor {


  final PreferredSizeProcessor _preferredSizeProcessor = PreferredSizeProcessor();
  final RegisterParentProcessor _registerParentCommand = RegisterParentProcessor();

  @override
  Future<List<BaseCommand>> processCommand(BaseCommand command) async {

    if(command is PreferredSizeCommand){
      return _preferredSizeProcessor.processCommand(command);
    } else if(command is RegisterParentCommand){
      return _registerParentCommand.processCommand(command);
    }

    return [];
  }

}