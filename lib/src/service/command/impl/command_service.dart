
import 'package:flutter_client/src/model/command/storage/delete_screen_command.dart';
import 'package:flutter_client/src/model/routing/route_to_menu.dart';
import 'package:flutter_client/src/routing/app_routing_type.dart';

import '../../../mixin/api_service_mixin.dart';
import '../../../mixin/config_service_mixin.dart';
import '../../../mixin/storage_service_mixin.dart';
import '../../../model/command/api/api_command.dart';
import '../../../model/command/base_command.dart';
import '../../../model/command/config/config_command.dart';
import '../../../model/command/layout/layout_command.dart';
import '../../../model/command/storage/storage_command.dart';
import '../../../model/command/ui/route_command.dart';
import '../../../model/command/ui/ui_command.dart';
import '../i_command_service.dart';
import '../shared/i_command_processor.dart';
import '../shared/processor/api/api_processor.dart';
import '../shared/processor/config/config_processor.dart';
import '../shared/processor/layout/layout_processor.dart';
import '../shared/processor/storage/storage_processor.dart';
import '../shared/processor/ui/ui_processor.dart';


/// [CommandService] is used to processCommands(facilitating communication between Services.
/// Will take in Commands and transfer them to a [ICommandProcessor] which will process its
/// contents, resulting in potentially more commands.
///
// Author: Michael Schober
class CommandService with ApiServiceMixin, ConfigServiceMixin, StorageServiceMixin implements ICommandService{


  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class Members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Will process all Commands with superclass [ApiCommand].
  final ICommandProcessor _apiProcessor = ApiProcessor();

  /// Will process all Commands with superclass [ConfigCommand].
  final ICommandProcessor _configProcessor = ConfigProcessor();

  /// Will process all Commands with superclass [StorageCommand].
  final ICommandProcessor _storageProcessor = StorageProcessor();

  /// Will process all Commands with superclass [UiCommand].
  final ICommandProcessor _uiProcessor = UiProcessor();

  /// Will process all Commands with superclass [LayoutCommand]
  final ICommandProcessor _layoutProcessor = LayoutProcessor();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
    } else if(command is LayoutCommand) {
      commands = _layoutProcessor.processCommand(command);
    }


    // Executes Commands resulting from incoming command.
    // Call routing commands dead last, all other actions must take priority.
    if(commands != null) {
      commands.then((value) {
        var executeFirst = value.where((element) => element is! RouteCommand);
        for (var value1 in executeFirst) {
          sendCommand(value1);
        }

        var routeCommand = value.whereType<RouteCommand>();
        for (var value2 in routeCommand) {
          sendCommand(value2);
        }

        if(value.any((element) => element is DeleteScreenCommand)){
          if(!value.any((element) => element is RouteCommand)){
            RouteCommand routeCommand = RouteCommand(routeType: AppRoutingType.menu, reason: "Last screen was closed and no other routing was passeed");
            sendCommand(routeCommand);
          }
        }
      });
    }
  }
}