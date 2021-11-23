import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/layout/preferred_size_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';
import 'package:flutter_client/src/service/command/shared/processor/layout/preferred_size_processort.dart';

class LayoutProcessor implements ICommandProcessor {


  final PreferredSizeProcessor _preferredSizeProcessor = PreferredSizeProcessor();

  @override
  Future<List<BaseCommand>> processCommand(BaseCommand command) async {

    if(command is PreferredSizeCommand){
      return _preferredSizeProcessor.processCommand(command);
    }

    return [];
  }

}