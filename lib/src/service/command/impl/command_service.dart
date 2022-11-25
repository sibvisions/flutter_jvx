import 'dart:async';

import 'package:collection/collection.dart';
import 'package:queue/queue.dart';

import '../../../../commands.dart';
import '../../../../flutter_jvx.dart';
import '../../../../services.dart';
import '../../../exceptions/error_view_exception.dart';
import '../../../exceptions/session_expired_exception.dart';
import '../../../model/command/base_command.dart';
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
  final Queue _apiCommandsQueue = Queue();

  /// List of all progress handler for commands
  final List<ICommandProgressHandler> progressHandler = [];

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  CommandService.create();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<void> sendCommand(BaseCommand pCommand) {
    // Only queue api commands
    if (pCommand is ApiCommand) {
      return _apiCommandsQueue.add(() => _sendCommand(pCommand));
    } else {
      return _sendCommand(pCommand);
    }
  }

  @override
  Future<void> sendCommands(List<BaseCommand> pCommands) {
    executeCommands() => Future.wait(pCommands.map((e) => _sendCommand(e)));
    // Only queue api commands
    if (pCommands.whereType<ApiCommand>().isNotEmpty) {
      return _apiCommandsQueue.add(executeCommands);
    } else {
      return executeCommands.call();
    }
  }

  Future<void> _sendCommand(BaseCommand pCommand) async {
    progressHandler.forEach((element) => element.notifyProgressStart(pCommand));

    try {
      FlutterJVx.logCommand.d("Started ${pCommand.runtimeType}-chain");
      await processCommand(pCommand);
      pCommand.onFinish?.call();
      FlutterJVx.logCommand.d("Finished ${pCommand.runtimeType}-chain");
    } catch (error) {
      FlutterJVx.logCommand.e("Error processing ${pCommand.runtimeType}-chain");
      rethrow;
    } finally {
      progressHandler.forEach((element) => element.notifyProgressEnd(pCommand));
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

  Future<void> processCommand(BaseCommand pCommand) async {
    if (pCommand is ApiCommand && pCommand is! DeviceStatusCommand) {
      FlutterJVx.logCommand.i("Processing ${pCommand.runtimeType}");
    }
    pCommand.beforeProcessing?.call();

    List<BaseCommand> commands = [];
    try {
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
        FlutterJVx.logCommand.w("Command (${pCommand.runtimeType}) without Processor found");
        return;
      }
    } on SessionExpiredException catch (e) {
      FlutterJVx.logCommand.w("Server sent HTTP ${e.statusCode}, session seems to be expired.");
      commands.add(OpenSessionExpiredDialogCommand(
        reason: "Server sent HTTP ${e.statusCode}",
      ));
    }

    FlutterJVx.logCommand.d("After processing ${pCommand.runtimeType}");
    pCommand.afterProcessing?.call();

    modifyCommands(commands, pCommand);
    IUiService().getAppManager()?.modifyCommands(commands, pCommand);

    if (commands.isNotEmpty) {
      FlutterJVx.logCommand.d("$pCommand\n->\n\t$commands");
    }

    // Executes Commands resulting from incoming command.
    // Call routing commands last, all other actions must take priority.

    // Isolate possible route commands
    var routeCommands = commands
        .where((element) =>
            element is RouteToWorkCommand || element is RouteToMenuCommand || element is RouteToLoginCommand)
        .toList();

    var nonRouteCommands = commands.where((element) => !routeCommands.contains(element)).toList();
    // nonRouteCommands.sort((a, b) => a.id.compareTo(b.id));

    try {
      // When all commands are finished execute routing commands sorted by priority
      await _waitTillFinished(pCommands: nonRouteCommands);

      // Don't route if there is a server error
      if (!nonRouteCommands.any((element) => element is OpenServerErrorDialogCommand)) {
        if (routeCommands.any((element) => element is RouteToLoginCommand)) {
          await processCommand(routeCommands.firstWhere((element) => element is RouteToLoginCommand));
        }
        if (routeCommands.any((element) => element is RouteToMenuCommand)) {
          await processCommand(routeCommands.firstWhere((element) => element is RouteToMenuCommand));
        }
        if (routeCommands.any((element) => element is RouteToWorkCommand)) {
          await processCommand(routeCommands.firstWhere((element) => element is RouteToWorkCommand));
        }
      }
    } catch (error) {
      FlutterJVx.logCommand.e("Error processing follow-up ${pCommand.runtimeType}");
      rethrow;
    }

    var errorCommand = nonRouteCommands.firstWhereOrNull((element) => element is OpenServerErrorDialogCommand)
        as OpenServerErrorDialogCommand?;
    if (errorCommand != null) {
      throw ErrorViewException(errorCommand);
    }
  }

  void modifyCommands(List<BaseCommand> commands, BaseCommand originalCommand) {
    if (originalCommand is OpenScreenCommand) {
      DeleteScreenCommand? deleteScreen =
          commands.firstWhereOrNull((element) => element is DeleteScreenCommand) as DeleteScreenCommand?;
      if (deleteScreen != null &&
          commands.any((element) => element is RouteToWorkCommand && element.screenName == deleteScreen.screenName)) {
        deleteScreen.beamBack = false;
      }
    }
  }
}
