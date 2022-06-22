import 'dart:async';

import 'package:flutter_client/src/model/command/ui/open_error_dialog_command.dart';
import 'package:flutter_client/src/model/command/ui/route_to_login_command.dart';
import 'package:flutter_client/src/model/command/ui/route_to_menu_command.dart';
import 'package:flutter_client/src/model/command/ui/route_to_work_command.dart';
import 'package:flutter_client/util/logging/flutter_logger.dart';

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
  Future<List<BaseCommand>> sendCommand(BaseCommand command) async {
    List<BaseCommand> commands = [];
    // Switch-Case doesn't work with types
    try {
      if (command is ApiCommand) {
        commands = await _apiProcessor.processCommand(command);
      } else if (command is ConfigCommand) {
        commands = await _configProcessor.processCommand(command);
      } else if (command is StorageCommand) {
        commands = await _storageProcessor.processCommand(command);
      } else if (command is UiCommand) {
        commands = await _uiProcessor.processCommand(command);
      } else if (command is LayoutCommand) {
        commands = await _layoutProcessor.processCommand(command);
      } else if (command is DataCommand) {
        commands = await _dataProcessor.processCommand(command);
      } else {
        LOGGER.logW(
          pType: LOG_TYPE.COMMAND,
          pMessage: "Command (${command.runtimeType}) without Processor found",
        );
        return [];
      }
    } catch (error, stacktrace) {
      LOGGER.logE(
        pType: LOG_TYPE.COMMAND,
        pMessage: "Error processing (${command.runtimeType}): ${error.toString()}",
        pStacktrace: stacktrace,
      );
    }

    // Executes Commands resulting from incoming command.
    // Call routing commands last, all other actions must take priority.

    // Isolate possible route commands
    var routeCommands = commands
        .where((element) => element is RouteToWorkCommand || element is RouteToMenuCommand || element is RouteToLoginCommand)
        .toList();

    var nonRouteCommands = commands.where((element) => !routeCommands.contains(element)).toList();
    // nonRouteCommands.sort((a, b) => a.id.compareTo(b.id));

    // When all commands are finished execute routing commands sorted by priority
    await _waitTillFinished(pCommands: nonRouteCommands).then((value) {
      if (nonRouteCommands.any((element) => element is OpenErrorDialogCommand)) {
        // Don't route if there is a server error
      } else if (routeCommands.any((element) => element is RouteToWorkCommand)) {
        return sendCommand(routeCommands.firstWhere((element) => element is RouteToWorkCommand));
      } else if (routeCommands.any((element) => element is RouteToMenuCommand)) {
        return sendCommand(routeCommands.firstWhere((element) => element is RouteToMenuCommand));
      } else if (routeCommands.any((element) => element is RouteToLoginCommand)) {
        return sendCommand(routeCommands.firstWhere((element) => element is RouteToLoginCommand));
      }
    });

    command.callback?.call();
    return commands;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns true when all provided commands have been executed
  _waitTillFinished({required List<BaseCommand> pCommands}) async {
    // Execute incoming commands
    for (BaseCommand command in pCommands) {
      await sendCommand(command);
    }
  }
}
