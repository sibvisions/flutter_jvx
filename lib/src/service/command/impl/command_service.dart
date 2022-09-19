import 'dart:async';
import 'dart:collection';

import '../../../../services.dart';
import '../../../../util/logging/flutter_logger.dart';
import '../../../model/command/api/api_command.dart';
import '../../../model/command/base_command.dart';
import '../../../model/command/config/config_command.dart';
import '../../../model/command/data/data_command.dart';
import '../../../model/command/layout/layout_command.dart';
import '../../../model/command/storage/storage_command.dart';
import '../../../model/command/ui/route_to_login_command.dart';
import '../../../model/command/ui/route_to_menu_command.dart';
import '../../../model/command/ui/route_to_work_command.dart';
import '../../../model/command/ui/ui_command.dart';
import '../../../model/command/ui/view/message/open_error_dialog_command.dart';
import '../../../util/loading_handler/i_command_progress_handler.dart';
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
class CommandService implements ICommandService {
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

  /// New api commands will be added to this list and
  /// will only be executed if the previous command and all of its follow-ups
  /// have finished execution (excluding layout-ing)
  final Queue<BaseCommand> _apiCommandsQueue = Queue();

  /// List of all progress handler for commands
  final List<ICommandProgressHandler> progressHandler = [];

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  CommandService();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<void> sendCommand(BaseCommand pCommand) async {
    // Same Command cant  be added twice, a previously added command will end up here when its called
    if (pCommand is ApiCommand && !_apiCommandsQueue.contains(pCommand)) {
      _apiCommandsQueue.add(pCommand);
      // If there is already a command in queue don't execute it
      if (_apiCommandsQueue.length > 1) {
        return;
      }
    }
    progressHandler.forEach((element) => element.notifyProgressStart(pCommand));

    List<BaseCommand>? routeCommands;
    try {
      routeCommands = await processCommand(pCommand);
      pCommand.callback?.call();
    } catch (error) {
      LOGGER.logE(pType: LogType.COMMAND, pMessage: "Error processing ${pCommand.runtimeType}");
      rethrow;
    } finally {
      progressHandler.forEach((element) => element.notifyProgressEnd(pCommand));

      try {
        if (routeCommands != null) {
          if (routeCommands.any((element) => element is RouteToWorkCommand)) {
            await processCommand(routeCommands.firstWhere((element) => element is RouteToWorkCommand));
          } else if (routeCommands.any((element) => element is RouteToMenuCommand)) {
            await processCommand(routeCommands.firstWhere((element) => element is RouteToMenuCommand));
          } else if (routeCommands.any((element) => element is RouteToLoginCommand)) {
            await processCommand(routeCommands.firstWhere((element) => element is RouteToLoginCommand));
          }
        }
      } catch (error) {
        LOGGER.logE(pType: LogType.COMMAND, pMessage: "Error processing follow-up ${pCommand.runtimeType}");
        rethrow;
      } finally {
        if (_apiCommandsQueue.remove(pCommand)) {
          // Remove current command after execution is complete
          // and call the next one in queue
          if (_apiCommandsQueue.isNotEmpty) {
            unawaited(sendCommand(_apiCommandsQueue.first));
          }
        }
      }
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns true when all provided commands have been executed
  _waitTillFinished({required List<BaseCommand> pCommands}) async {
    // Execute incoming commands
    for (BaseCommand command in pCommands) {
      await processCommand(command);
    }
  }

  Future<List<BaseCommand>> processCommand(BaseCommand pCommand) async {
    List<BaseCommand> commands = [];
    // Switch-Case doesn't work with types
    if (pCommand is ApiCommand) {
      commands = await _apiProcessor.processCommand(pCommand);
    } else if (pCommand is ConfigCommand) {
      commands = await _configProcessor.processCommand(pCommand);
    } else if (pCommand is StorageCommand) {
      commands = await _storageProcessor.processCommand(pCommand);
    } else if (pCommand is UiCommand) {
      commands = await _uiProcessor.processCommand(pCommand);
    } else if (pCommand is LayoutCommand) {
      commands = await _layoutProcessor.processCommand(pCommand);
    } else if (pCommand is DataCommand) {
      commands = await _dataProcessor.processCommand(pCommand);
    } else {
      LOGGER.logW(
        pType: LogType.COMMAND,
        pMessage: "Command (${pCommand.runtimeType}) without Processor found",
      );
      return [];
    }

    IUiService().getAppManager()?.modifyCommands(commands, pCommand);

    // Executes Commands resulting from incoming command.
    // Call routing commands last, all other actions must take priority.

    // Isolate possible route commands
    var routeCommands = commands
        .where((element) =>
            element is RouteToWorkCommand || element is RouteToMenuCommand || element is RouteToLoginCommand)
        .toList();

    var nonRouteCommands = commands.where((element) => !routeCommands.contains(element)).toList();
    // nonRouteCommands.sort((a, b) => a.id.compareTo(b.id));

    // When all commands are finished execute routing commands sorted by priority
    await _waitTillFinished(pCommands: nonRouteCommands);

    if (!nonRouteCommands.any((element) => element is OpenErrorDialogCommand)) {
      return routeCommands;
    } else {
      // Don't route if there is a server error
      return [];
    }
  }
}
