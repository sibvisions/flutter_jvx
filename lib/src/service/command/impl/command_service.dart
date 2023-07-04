/*
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:queue/queue.dart';

import '../../../exceptions/error_view_exception.dart';
import '../../../exceptions/session_expired_exception.dart';
import '../../../flutter_ui.dart';
import '../../../model/command/api/api_command.dart';
import '../../../model/command/api/device_status_command.dart';
import '../../../model/command/api/exit_command.dart';
import '../../../model/command/api/session_command.dart';
import '../../../model/command/base_command.dart';
import '../../../model/command/config/config_command.dart';
import '../../../model/command/data/data_command.dart';
import '../../../model/command/layout/layout_command.dart';
import '../../../model/command/queue_command.dart';
import '../../../model/command/storage/delete_screen_command.dart';
import '../../../model/command/storage/storage_command.dart';
import '../../../model/command/ui/route/route_command.dart';
import '../../../model/command/ui/route/route_to_command.dart';
import '../../../model/command/ui/route/route_to_login_command.dart';
import '../../../model/command/ui/route/route_to_menu_command.dart';
import '../../../model/command/ui/route/route_to_work_command.dart';
import '../../../model/command/ui/ui_command.dart';
import '../../../model/command/ui/view/message/open_server_error_dialog_command.dart';
import '../../../model/command/ui/view/message/open_session_expired_dialog_command.dart';
import '../../../util/loading_handler/i_command_progress_handler.dart';
import '../../ui/i_ui_service.dart';
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
  /// have finished execution
  final Queue _commandsQueue = Queue();

  /// New layout commands will be added to this list and
  /// will only be executed if the previous command and all of its follow-ups
  /// have finished execution
  final Queue _layoutCommandsQueue = Queue();

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
  FutureOr<void> clear(bool pFullClear) async {
    if (pFullClear) {
      // drain queue up to this point
      await _commandsQueue.add(() => Future.value(null));
      await _layoutCommandsQueue.add(() => Future.value(null));
    }
  }

  @override
  Future<void> sendCommand(BaseCommand pCommand) {
    BaseCommand command = IUiService().getAppManager()?.interceptCommand(pCommand) ?? pCommand;
    // Only queue layout commands
    if (command is LayoutCommand) {
      return _layoutCommandsQueue.add(() => _sendCommand(command));
    }
    // Only queue queue commands
    else if (command is QueueCommand) {
      return _commandsQueue.add(() => _sendCommand(command));
    }

    return _sendCommand(command);
  }

  Future<void> _sendCommand(BaseCommand pCommand) async {
    try {
      progressHandler.forEach((element) => element.notifyProgressStart(pCommand));

      // Discard SessionCommands which are sent from an older session (e.g. dispose sends an command).
      if (pCommand is SessionCommand && pCommand.clientId != IUiService().clientId.value) {
        FlutterUI.logCommand.d("${pCommand.runtimeType} uses old/invalid Client ID, discarding.");
        return;
      }

      FlutterUI.logCommand.d("Started ${pCommand.runtimeType}-chain");
      await processCommand(pCommand, null);
      await pCommand.onFinish?.call();
      FlutterUI.logCommand.d("Finished ${pCommand.runtimeType}-chain");
    } catch (error) {
      FlutterUI.logCommand.e("Error processing ${pCommand.runtimeType}-chain");
      rethrow;
    } finally {
      progressHandler.forEach((element) => element.notifyProgressEnd(pCommand));
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns true when all provided commands have been executed
  _waitTillFinished(List<BaseCommand> pCommands, {BaseCommand? origin}) async {
    // Execute incoming commands
    for (BaseCommand command in pCommands) {
      await processCommand(command, origin);
    }
  }

  Future<void> processCommand(BaseCommand pCommand, BaseCommand? origin) async {
    if (pCommand is ApiCommand && pCommand is! DeviceStatusCommand) {
      FlutterUI.logCommand.i("Processing ${pCommand.runtimeType} (${pCommand.reason})");
    }
    await pCommand.beforeProcessing?.call();

    List<BaseCommand> commands = [];
    try {
      // Switch-Case doesn't work with types
      if (pCommand is ApiCommand) {
        commands = await _apiProcessor.processCommand(pCommand, origin);
      } else if (pCommand is ConfigCommand) {
        commands = await _configProcessor.processCommand(pCommand, origin);
      } else if (pCommand is StorageCommand) {
        commands = await _storageProcessor.processCommand(pCommand, origin);
      } else if (pCommand is UiCommand) {
        commands = await _uiProcessor.processCommand(pCommand, origin);
      } else if (pCommand is LayoutCommand) {
        commands = await _layoutProcessor.processCommand(pCommand, origin);
      } else if (pCommand is DataCommand) {
        commands = await _dataProcessor.processCommand(pCommand, origin);
      } else {
        FlutterUI.logCommand.w("Command (${pCommand.runtimeType}) without Processor found");
        return;
      }
    } on SessionExpiredException catch (e) {
      // Don't process ExitCommands
      if (pCommand is ExitCommand) {
        return;
      }
      FlutterUI.logCommand.w("Server sent HTTP ${e.statusCode}, session seems to be expired.");
      commands.add(OpenSessionExpiredDialogCommand(
        reason: "Server sent HTTP ${e.statusCode}",
      ));
    }

    // Don't process ExitCommands
    if (pCommand is ExitCommand) {
      return;
    }

    FlutterUI.logCommand.d("After processing ${pCommand.runtimeType}");
    await pCommand.afterProcessing?.call();

    modifyCommands(commands, pCommand);
    IUiService().getAppManager()?.modifyFollowUpCommands(pCommand, commands);

    if (commands.isNotEmpty) {
      FlutterUI.logCommand.d("$pCommand\n->\n\t$commands");
    }

    // Executes Commands resulting from incoming command.
    // Call routing commands last, all other actions must take priority.

    // Isolate possible route commands
    var routeCommands = commands.whereType<RouteCommand>().toList();

    var nonRouteCommands = commands.where((element) => !routeCommands.contains(element)).toList();
    // nonRouteCommands.sort((a, b) => a.id.compareTo(b.id));

    try {
      // When all commands are finished execute routing commands sorted by priority
      await _waitTillFinished(nonRouteCommands, origin: pCommand);

      // Don't route if there is a server error
      if (!nonRouteCommands.any((element) => element is OpenServerErrorDialogCommand)) {
        if (routeCommands.any((element) => element is RouteToLoginCommand)) {
          await processCommand(routeCommands.firstWhere((element) => element is RouteToLoginCommand), pCommand);
        }
        if (routeCommands.any((element) => element is RouteToMenuCommand)) {
          await processCommand(routeCommands.firstWhere((element) => element is RouteToMenuCommand), pCommand);
        }
        if (routeCommands.any((element) => element is RouteToWorkCommand)) {
          await processCommand(routeCommands.firstWhere((element) => element is RouteToWorkCommand), pCommand);
        }
        if (routeCommands.any((element) => element is RouteToCommand)) {
          await processCommand(routeCommands.firstWhere((element) => element is RouteToCommand), pCommand);
        }
      }
    } catch (error) {
      FlutterUI.logCommand.e("Error processing follow-up ${pCommand.runtimeType}");
      rethrow;
    }

    var errorCommand = nonRouteCommands.firstWhereOrNull((element) => element is OpenServerErrorDialogCommand)
        as OpenServerErrorDialogCommand?;
    if (errorCommand != null) {
      throw ErrorViewException(errorCommand);
    }

    var sessionExpiredCommand = nonRouteCommands
        .firstWhereOrNull((element) => element is OpenSessionExpiredDialogCommand) as OpenSessionExpiredDialogCommand?;
    if (sessionExpiredCommand != null) {
      throw SessionExpiredException();
    }
  }

  void modifyCommands(List<BaseCommand> commands, BaseCommand origin) {
    if (commands.any((element) => element is RouteToWorkCommand)) {
      commands.whereType<DeleteScreenCommand>().forEach((element) {
        element.beamBack = false;
      });
    }
  }
}
