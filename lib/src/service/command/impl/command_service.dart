import 'dart:developer';

import 'package:flutter_client/src/mixin/api_service_mixin.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:flutter_client/src/mixin/storage_service_mixin.dart';
import 'package:flutter_client/src/model/command/api/api_command.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/config/config_command.dart';
import 'package:flutter_client/src/model/command/storage/storage_command.dart';
import 'package:flutter_client/src/model/command/ui/route_command.dart';
import 'package:flutter_client/src/model/command/ui/ui_command.dart';
import 'package:flutter_client/src/service/command/i_command_service.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';
import 'package:flutter_client/src/service/command/shared/processor/api/api_processor.dart';
import 'package:flutter_client/src/service/command/shared/processor/config/config_processor.dart';
import 'package:flutter_client/src/service/command/shared/processor/storage/storage_processor.dart';
import 'package:flutter_client/src/service/command/shared/processor/ui/ui_processor.dart';
import 'package:flutter_client/src/service/ui/i_ui_service.dart';

import '../../service.dart';

class CommandService with ApiServiceMixin, ConfigServiceMixin, StorageServiceMixin implements ICommandService{


  // One Processor for every Service
  final ICommandProcessor _apiProcessor = ApiProcessor();
  final ICommandProcessor _configProcessor = ConfigProcessor();
  final ICommandProcessor _storageProcessor = StorageProcessor();
  final ICommandProcessor _uiProcessor = UiProcessor();


  @override
  sendCommand(BaseCommand command) {
    Future<List<BaseCommand>>? commands;

    // Switch-Case doesn't work with types
    if(command is ApiCommand){
      commands = _apiProcessor.processCommand(command);
    } else if(command is ConfigCommand) {
      commands = _configProcessor.processCommand(command);
    } else if(command is StorageCommand) {
      commands = _storageProcessor.processCommand(command);
    } else if(command is UiCommand) {
      commands = _uiProcessor.processCommand(command);
    }


    // IF services want to execute Commands, eg. tell other services to do something.
    // Mainly used for API Service.
    if(commands != null) {
      //Call routing commands dead last, all other actions take priority
      commands.then((value) {
        var executeFirst = value.where((element) => element is! RouteCommand);
        for (var value1 in executeFirst) {
          sendCommand(value1);
        }
        var routeCommand = value.whereType<RouteCommand>();
        for (var value2 in routeCommand) {
          sendCommand(value2);
        }
      });
    }
  }

  //UIService and Command service can't depend on another when using mixins
  IUiService _getUiService(){
    return services<IUiService>();
  }

}