import 'package:flutter_client/src/model/command/ui/route_to_work_command.dart';
import 'package:flutter_client/src/model/command/ui/route_to_menu_command.dart';

import '../../../mixin/api_service_mixin.dart';
import '../../../mixin/config_service_mixin.dart';
import '../../../mixin/storage_service_mixin.dart';
import '../../../model/command/api/api_command.dart';
import '../../../model/command/base_command.dart';
import '../../../model/command/config/config_command.dart';
import '../../../model/command/data/data_command.dart';
import '../../../model/command/layout/layout_command.dart';
import '../../../model/command/storage/storage_command.dart';
import '../../../model/command/ui/ui_command.dart';
import '../i_command_service.dart';
import '../shared/i_command_processor.dart';
import '../shared/processor/api/api_processor.dart';
import '../shared/processor/config/config_processor.dart';
import '../shared/processor/data/data_processor.dart';
import '../shared/processor/layout/layout_processor.dart';
import '../shared/processor/storage/storage_processor.dart';
import '../shared/processor/ui/ui_processor.dart';

/// [CommandService] is used to processCommands(facilitating communication between Services.
/// Will take in Commands and transfer them to a [ICommandProcessor] which will process its
/// contents, resulting in potentially more commands.
///
// Author: Michael Schober
class CommandService with ApiServiceMixin, ConfigServiceMixin, StorageServiceMixin implements ICommandService {
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

  /// Will process all Commands with superclass [DataCommand]
  final ICommandProcessor _dataProcessor = DataProcessor();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<List<BaseCommand>> sendCommand(BaseCommand command) {

    Future<List<BaseCommand>>? commands;

    // Switch-Case doesn't work with types
    if (command is ApiCommand) {
      commands = _apiProcessor.processCommand(command);
    } else if (command is ConfigCommand) {
      commands = _configProcessor.processCommand(command);
    } else if (command is StorageCommand) {
      commands = _storageProcessor.processCommand(command);
    } else if (command is UiCommand) {
      commands = _uiProcessor.processCommand(command);
    } else if (command is LayoutCommand) {
      commands = _layoutProcessor.processCommand(command);
    } else if (command is DataCommand) {
      commands = _dataProcessor.processCommand(command);
    }

    // Executes Commands resulting from incoming command.
    // Call routing commands last, all other actions must take priority.
    if (commands != null) {
      commands.then((resultCommands) {

        // Isolate possible route commands
        var routeCommands = resultCommands.where((element) =>
        element is RouteToWorkCommand || element is RouteToMenuCommand).toList();

        var nonRouteCommands = resultCommands.where((element) =>
        element is! RouteToWorkCommand && element is! RouteToMenuCommand).toList();

        // When all commands are finished execute routing commands sorted by priority
        _waitTillFinished(pCommands: nonRouteCommands).then((value) {
          if(routeCommands.any((element) => element is RouteToWorkCommand)){
            sendCommand(routeCommands.firstWhere((element) => element is RouteToWorkCommand));
          } else if(routeCommands.any((element) => element is RouteToMenuCommand)){
            sendCommand(routeCommands.firstWhere((element) => element is RouteToMenuCommand));
          }
        });
      });
    }
    return commands!;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns true when all provided commands have been executed recursively
  Future<bool> _waitTillFinished({required List<BaseCommand> pCommands}) async {

    // Execute incoming commands
    for (BaseCommand command in pCommands) {
      await sendCommand(command);
    }

    // Execute all unfinished command flows and only return true if all commands
    // return an empty command list
    return true;
  }
}


