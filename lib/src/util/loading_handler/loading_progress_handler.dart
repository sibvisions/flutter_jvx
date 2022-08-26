import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';

import '../../../util/logging/flutter_logger.dart';
import '../../model/command/api/api_command.dart';
import '../../model/command/api/change_password_command.dart';
import '../../model/command/api/device_status_command.dart';
import '../../model/command/api/download_images_command.dart';
import '../../model/command/api/download_style_command.dart';
import '../../model/command/api/download_translation_command.dart';
import '../../model/command/api/login_command.dart';
import '../../model/command/api/logout_command.dart';
import '../../model/command/api/reset_password_command.dart';
import '../../model/command/api/startup_command.dart';
import '../../model/command/base_command.dart';
import '../../model/command/config/config_command.dart';
import '../../model/command/data/data_command.dart';
import '../../model/command/layout/layout_command.dart';
import '../../model/command/ui/ui_command.dart';
import '../../service/command/i_command_service.dart';
import '../../service/command/impl/command_service.dart';
import '../../service/service.dart';
import '../../service/ui/i_ui_service.dart';
import 'i_command_progress_handler.dart';

/// The [LoadingProgressHandler] shows a loading progress if a request is over its defined threshold for the wait time.
class LoadingProgressHandler implements ICommandProgressHandler {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Map of all timers for every call.
  final Map<BaseCommand, Timer> _commandTimerMap = {};

  /// If this is enabled
  bool isEnabled = false;

  /// The context of the popup
  BuildContext? _dialogContext;

  /// Amount of requests that have called for a loading progress.
  int _loadingCommandAmount = 0;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void notifyCommandProgressStart(BaseCommand pCommand) async {
    if (isSupported(pCommand)) {
      LOGGER.logD(
          pType: LogType.COMMAND,
          pMessage: "notifyCommandProgressStart: ${pCommand.runtimeType} + ${pCommand.hashCode}");
      _commandTimerMap[pCommand] = Timer(pCommand.loadingDelay, () {
        if (_commandTimerMap[pCommand] != null) {
          _showLoadingProgress(pCommand);
        }
      });
    }
  }

  @override
  void notifyCommandProgressEnd(BaseCommand pCommand) async {
    Timer? timer = _commandTimerMap.remove(pCommand);
    if (timer != null) {
      if (timer.isActive) {
        timer.cancel();
        LOGGER.logD(pType: LogType.COMMAND, pMessage: "Timer cancel: ${pCommand.runtimeType} + ${pCommand.hashCode}");
      } else {
        _closeLoadingProgress(pCommand);
      }
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  static void setEnabled(bool enabled) {
    (services<ICommandService>() as CommandService)
        .progressHandler
        .whereType<LoadingProgressHandler>()
        .forEach((element) => element.isEnabled = enabled);
  }

  void _showLoadingProgress(BaseCommand pCommand) {
    if (_commandTimerMap[pCommand] == null) {
      return;
    }

    //Only show loading dialog if there isn't any other dialog
    if (ModalRoute.of(IUiService.getCurrentContext())?.isCurrent == false) {
      return;
    }

    LOGGER.logD(
      pType: LogType.COMMAND,
      pMessage: "showLoadingProgress | $_loadingCommandAmount | ${pCommand.runtimeType} + ${pCommand.hashCode}",
    );
    if (_loadingCommandAmount == 0) {
      try {
        services<IUiService>().openDialog(
          pDialogWidget: _createLoadingProgressIndicator(),
          pIsDismissible: false,
          pContextCallback: (context) {
            if (_loadingCommandAmount == 0) {
              try {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              } catch (exception) {
                log("Error while popping loading progress handler", error: exception);
              }
            } else {
              _dialogContext = context;
            }
          },
        );
      } catch (exception) {
        //Ignore
      }
    }
    _loadingCommandAmount++;
  }

  void _closeLoadingProgress(BaseCommand pCommand) {
    _loadingCommandAmount--;
    LOGGER.logD(
      pType: LogType.COMMAND,
      pMessage: "closeLoadingProgress | $_loadingCommandAmount |  ${pCommand.runtimeType} + ${pCommand.hashCode}",
    );
    if (_loadingCommandAmount == 0 && _dialogContext != null) {
      try {
        if (Navigator.canPop(_dialogContext!)) {
          Navigator.pop(_dialogContext!);
        }
      } catch (_) {
        //Ignore
      } finally {
        _dialogContext = null;
      }
    }
  }

  Widget _createLoadingProgressIndicator() {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Align(
        alignment: Alignment.center,
        child: Opacity(
          opacity: 0.7,
          child: Container(
            width: 100,
            height: 100,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [CircularProgressIndicator.adaptive()],
            ),
          ),
        ),
      ),
    );
  }

  bool isSupported(BaseCommand pCommand) {
    if (!isEnabled) {
      return false;
    }

    if (pCommand is LayoutCommand) {
      return false;
    }

    if (pCommand is ConfigCommand) {
      return false;
    }

    if (pCommand is UiCommand) {
      return false;
    }

    if (pCommand is DataCommand) {
      return true;
    }

    if (pCommand is ApiCommand) {
      if (pCommand is StartupCommand ||
          pCommand is LoginCommand ||
          pCommand is LogoutCommand ||
          pCommand is ChangePasswordCommand ||
          pCommand is DeviceStatusCommand ||
          pCommand is DownloadImagesCommand ||
          pCommand is DownloadStyleCommand ||
          pCommand is DownloadTranslationCommand ||
          pCommand is ResetPasswordCommand) {
        return false;
      }
      // if (pCommand is DeleteRecordCommand ||
      //     pCommand is FetchCommand ||
      //     pCommand is FilterCommand ||
      //     pCommand is InsertRecordCommand ||
      //     pCommand is PressButtonCommand ||
      //     pCommand is SelectRecordCommand ||
      //     pCommand is SetValueCommand ||
      //     pCommand is SetValuesCommand) {
      //   return true;
      // }
      return true;
    }

    return true;
  }
}
