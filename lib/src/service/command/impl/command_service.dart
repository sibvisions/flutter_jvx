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
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:queue/queue.dart';

import '../../../commands.dart';
import '../../../flutter_ui.dart';
import '../../../model/command/api/alive_command.dart';
import '../../../model/command/api/application_command.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../model/menu/menu_item_model.dart';
import '../../../util/jvx_logger.dart';
import '../../../util/loading_handler/i_command_progress_handler.dart';
import '../../api/i_api_service.dart';
import '../../api/shared/repository/online_api_repository.dart';
import '../../service.dart';
import '../../storage/i_storage_service.dart';
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

  final ApiProcessor _apiProcessor = ApiProcessor();
  final ConfigProcessor _configProcessor = ConfigProcessor();
  final StorageProcessor _storageProcessor = StorageProcessor();
  final UiProcessor _uiProcessor = UiProcessor();
  final LayoutProcessor _layoutProcessor = LayoutProcessor();
  final DataProcessor _dataProcessor = DataProcessor();

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
  FutureOr<void> clear(ClearReason reason) async {
    if (reason.isFull()) {
      // drain queue up to this point
      await _commandsQueue.add(() => Future.value(null));
      await _layoutCommandsQueue.add(() => Future.value(null));
    }
  }

  @override
  Future<bool> sendCommand(
    BaseCommand pCommand, {
    bool showDialogOnError = true,
    bool throwFirstErrorCommand = false,
    bool? delayUILocking,
    bool? showLoading,
  }) async {
    BaseCommand command = IUiService().getAppManager()?.interceptCommand(pCommand) ?? pCommand;
    // Only queue layout commands
    if (command is LayoutCommand) {
      return _layoutCommandsQueue.add(() => _initCommandProcessing(command, false));
    }
    // Only queue queue commands
    else if (command is IQueueCommand) {
      return _commandsQueue.add(() =>
          _initCommandProcessing(command, showDialogOnError, throwFirstErrorCommand, delayUILocking, showLoading));
    }

    return _initCommandProcessing(command, showDialogOnError, throwFirstErrorCommand, delayUILocking, showLoading);
  }

  @override
  Future<bool> sendCommands(
    List<BaseCommand> commands, {
    bool showDialogOnError = true,
    bool abortOnFirstError = false,
    bool? delayUILocking,
    bool? showLoading,
  }) async {
    bool success = true;
    bool first = true;

    for (BaseCommand command in commands) {
      success = await sendCommand(command,
              showDialogOnError: showDialogOnError,
              delayUILocking: first ? delayUILocking : null,
              showLoading: first ? showLoading : null) &&
          success;
      first = false;
      if (!success && abortOnFirstError) {
        break;
      }
    }

    return success;
  }

  Future<bool> _initCommandProcessing(
    BaseCommand pCommand,
    bool showDialogOnError, [
    bool throwFirstErrorCommand = false,
    bool? delayUILocking,
    bool? showLoading,
  ]) async {
    try {
      pCommand.delayUILocking = delayUILocking ?? pCommand.delayUILocking;
      pCommand.showLoading = showLoading ?? pCommand.showLoading;

      try {
        progressHandler.forEach((element) => element.notifyProgressStart(pCommand));
      } catch (e) {
        FlutterUI.logCommand.d("Error notifying progress start");
      }

      // Discard SessionCommands which are sent from an older session (e.g. dispose sends an command).
      if (pCommand is ApplicationCommand && pCommand.clientId != IUiService().clientId.value) {
        if (FlutterUI.logCommand.cl(Lvl.d)) {
          FlutterUI.logCommand.d("${pCommand.runtimeType} uses old/invalid Client ID, discarding.");
        }

        return false;
      }

      if (FlutterUI.logCommand.cl(Lvl.d)) {
        FlutterUI.logCommand.d("Started ${pCommand.runtimeType}-chain");
      }

      List<BaseCommand>? followCommands = await processCommand(pCommand, null, showDialogOnError);
      ErrorCommand? firstErrorCommand;

      while (followCommands != null) {
        firstErrorCommand ??= followCommands.whereType<ErrorCommand>().firstOrNull;

        List<BaseCommand>? newFollowCommands;

        for (BaseCommand followCommand in followCommands) {
          List<BaseCommand>? newCommands = await processCommand(followCommand, pCommand, showDialogOnError);
          if (newCommands != null) {
            newFollowCommands ??= [];
            newFollowCommands.addAll(newCommands);
          }
        }

        followCommands = newFollowCommands;
      }

      await getProcessor(pCommand)?.onFinish(pCommand);

      if (FlutterUI.logCommand.cl(Lvl.d)) {
        FlutterUI.logCommand.d("Finished ${pCommand.runtimeType}-chain");
      }

      if (firstErrorCommand != null) {
        throw firstErrorCommand;
      }

      return true;
    } catch (error) {
      if (FlutterUI.logCommand.cl(Lvl.e)) {
        FlutterUI.logCommand.e("Error processing ${pCommand.runtimeType}-chain");
      }

      if (throwFirstErrorCommand) {
        rethrow;
      } else {
        return false;
      }
    } finally {
      try {
        progressHandler.forEach((element) => element.notifyProgressEnd(pCommand));
      } catch (e) {
        FlutterUI.logCommand.d("Error notifying progress end");
      }
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Future<List<BaseCommand>?> processCommand(BaseCommand pCommand, BaseCommand? origin, bool showDialogOnError) async {
    if (pCommand is ApiCommand && pCommand is! DeviceStatusCommand) {
      FlutterUI.logCommand.i("Processing ${pCommand.runtimeType} (${pCommand.reason})");
    }

    ICommandProcessor<BaseCommand>? processor = getProcessor(pCommand);

    if (processor == null) {
      if (FlutterUI.logCommand.cl(Lvl.e)) {
        FlutterUI.logCommand.e("Command (${pCommand.runtimeType}) without Processor found");
      }

      return null;
    }

    List<BaseCommand> commands;

    bool wasConnected = true;

    var repository = IApiService().getRepository();

    if (repository is OnlineApiRepository) {
      wasConnected = repository.connected;
    }

    try {
      await processor.beforeProcessing(pCommand, origin);

      commands = await processor.processCommand(pCommand, origin);

      // Don't process ExitCommands
      if (pCommand is ExitCommand) {
        return null;
      }

      if (FlutterUI.logCommand.cl(Lvl.d)) {
        FlutterUI.logCommand.d("After processing ${pCommand.runtimeType}");
      }
      await processor.afterProcessing(pCommand, origin);

      modifyCommands(commands, pCommand);
      IUiService().getAppManager()?.modifyFollowUpCommands(pCommand, commands);

      if (FlutterUI.logCommand.cl(Lvl.d)) {
        if (commands.isNotEmpty) {
          FlutterUI.logCommand.d("$pCommand\n->\n\t$commands");
        }
      }
    } catch (error, stackTrace) {
      if (FlutterUI.logAPI.cl(Lvl.e)) {
        FlutterUI.logAPI.e("Error while processing ${pCommand.runtimeType} with ${processor.runtimeType} $error");
      }

      bool isConnectionError = error is TimeoutException || error is SocketException || error is DioException;

      if (pCommand is! ErrorCommand && pCommand is! FeedbackCommand) {

        bool showError = true;

        if (pCommand is AliveCommand) {
          if (!wasConnected) {
            showError = false;
          }
        }

        if (showError) {
          commands = [
            OpenErrorDialogCommand(
              silentAbort: !showDialogOnError,
              message: FlutterUI.translate(IUiService.getErrorMessage(error)),
              error: error,
              stackTrace: stackTrace,
              isTimeout: isConnectionError,
              reason: "Failed processing ${pCommand.runtimeType}",
            ),
          ];
        }
        else {
          commands = [];
        }

        // If there is a current session and a "probably" working connection, report to the server.
        if (!isConnectionError && IUiService().clientId.value != null) {
          commands.add(
            FeedbackCommand(
              type: FeedbackType.Error,
              message: IUiService.getErrorMessage(error),
              properties: {
                "error": error.toString(),
              },
              reason: "UIService async error",
            ),
          );
        }
      } else {
        commands = [];
      }
    }

    return commands;
  }

  ICommandProcessor<BaseCommand>? getProcessor(BaseCommand pCommand) {
    ICommandProcessor? processor;
    if (pCommand is ApiCommand) {
      processor = _apiProcessor.getProcessor(pCommand);
    } else if (pCommand is ConfigCommand) {
      processor = _configProcessor.getProcessor(pCommand);
    } else if (pCommand is StorageCommand) {
      processor = _storageProcessor.getProcessor(pCommand);
    } else if (pCommand is UiCommand) {
      processor = _uiProcessor.getProcessor(pCommand);
    } else if (pCommand is LayoutCommand) {
      processor = _layoutProcessor.getProcessor(pCommand);
    } else if (pCommand is DataCommand) {
      processor = _dataProcessor.getProcessor(pCommand);
    }
    return processor;
  }

  void modifyCommands(List<BaseCommand> commands, BaseCommand origin) {
    commands.whereType<DeleteScreenCommand>().where((deleteScreen) {
      Set<String> setNamesOfScreen = {deleteScreen.componentName};

      FlComponentModel? screenModel = IStorageService().getComponentByName(pComponentName: deleteScreen.componentName);
      if (screenModel is FlPanelModel) {
        if (screenModel.screenNavigationName != null) {
          setNamesOfScreen.add(screenModel.screenNavigationName!);
        }
        if (screenModel.screenClassName != null) {
          setNamesOfScreen.add(screenModel.screenClassName!);
        }
        if (screenModel.screenTitle != null) {
          setNamesOfScreen.add(screenModel.screenTitle!);
        }
      }

      MenuItemModel? menuItemModel;
      for (String screenName in setNamesOfScreen) {
        menuItemModel = IUiService().getMenuItem(screenName);
        if (menuItemModel != null) {
          setNamesOfScreen.add(menuItemModel.label);
          setNamesOfScreen.add(menuItemModel.navigationName);
          setNamesOfScreen.add(menuItemModel.screenLongName);
          break;
        }
      }

      return commands
          .whereType<RouteToWorkScreenCommand>()
          .any((routeToWork) => setNamesOfScreen.contains(routeToWork.screenName));
    }).forEach((element) {
      element.popPage = false;
    });
  }
}
