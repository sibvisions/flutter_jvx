import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_client/src/model/command/api/change_password_command.dart';
import 'package:flutter_client/src/model/command/api/device_status_command.dart';
import 'package:flutter_client/src/model/command/api/download_images_command.dart';
import 'package:flutter_client/src/model/command/api/download_style_command.dart';
import 'package:flutter_client/src/model/command/api/download_translation_command.dart';
import 'package:flutter_client/src/model/command/api/login_command.dart';
import 'package:flutter_client/src/model/command/api/logout_command.dart';
import 'package:flutter_client/src/model/command/api/open_screen_command.dart';
import 'package:flutter_client/src/model/command/api/reset_password_command.dart';
import 'package:flutter_client/src/model/command/api/startup_command.dart';
import 'package:flutter_client/src/model/command/config/config_command.dart';
import 'package:flutter_client/src/model/command/data/data_command.dart';
import 'package:flutter_client/src/model/command/layout/layout_command.dart';
import 'package:flutter_client/src/model/command/ui/ui_command.dart';
import 'package:flutter_client/util/logging/flutter_logger.dart';

import '../../src/model/command/api/api_command.dart';
import '../../src/model/command/base_command.dart';
import '../../src/service/service.dart';
import '../../src/service/ui/i_ui_service.dart';
import 'i_command_progress_handler.dart';

/// The [DefaultLoadingProgressHandler] shows a loading progress if a request is over its defined threshold for the wait time.
class DefaultLoadingProgressHandler implements ICommandProgressHandler {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Map of all timers for every call.
  final Map<BaseCommand, Timer> _commandTimerMap = {};

  /// If this is enabled
  bool isEnabled = true;

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
          pType: LOG_TYPE.COMMAND,
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
        LOGGER.logD(pType: LOG_TYPE.COMMAND, pMessage: "Timer cancel: ${pCommand.runtimeType} + ${pCommand.hashCode}");
      } else {
        _closeLoadingProgress(pCommand);
      }
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void _showLoadingProgress(BaseCommand pCommand) {
    if (_commandTimerMap[pCommand] == null) {
      return;
    }

    LOGGER.logD(
      pType: LOG_TYPE.COMMAND,
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
                Navigator.pop(context);
              } catch (exception) {
                log(exception.toString());
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
      pType: LOG_TYPE.COMMAND,
      pMessage: "closeLoadingProgress | $_loadingCommandAmount |  ${pCommand.runtimeType} + ${pCommand.hashCode}",
    );
    if (_loadingCommandAmount == 0 && _dialogContext != null) {
      try {
        Navigator.pop(_dialogContext!);
      } catch (_) {
        //Ignore
      } finally {
        _dialogContext = null;
      }
    }
  }

  Widget _createLoadingProgressIndicator() {
    return WillPopScope(
      onWillPop: _willPop,
      child: const Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: 25.0,
          height: 25.0,
          child: CircularProgressIndicator.adaptive(),
        ),
      ),
    );
  }

  Future<bool> _willPop() async {
    return false;
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
          pCommand is ResetPasswordCommand ||
          pCommand is OpenScreenCommand) {
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
