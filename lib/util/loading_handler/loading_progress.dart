import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';

import '../../src/model/command/api/api_command.dart';
import '../../src/model/command/api/delete_record_command.dart';
import '../../src/model/command/api/fetch_command.dart';
import '../../src/model/command/api/filter_command.dart';
import '../../src/model/command/api/insert_record_command.dart';
import '../../src/model/command/api/press_button_command.dart';
import '../../src/model/command/api/select_record_command.dart';
import '../../src/model/command/api/set_value_command.dart';
import '../../src/model/command/api/set_values_command.dart';
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
      log("Start: ${pCommand.runtimeType} + ${pCommand.hashCode}");
      Duration duration = durationForCommand(pCommand);
      _commandTimerMap[pCommand] = Timer(duration, _showLoadingProgress);
    }
  }

  @override
  void notifyCommandProgressEnd(BaseCommand pCommand) async {
    Timer? timer = _commandTimerMap.remove(pCommand);
    if (timer != null) {
      log("End: ${pCommand.runtimeType} + ${pCommand.hashCode}");
      if (timer.isActive) {
        timer.cancel();
      } else {
        _closeLoadingProgress();
      }
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void _showLoadingProgress() {
    log("showLoadingProgress | $_loadingCommandAmount");
    if (_loadingCommandAmount == 0) {
      services<IUiService>().openDialog(
        pDialogWidget: _createLoadingProgressIndicator(),
        pIsDismissible: false,
        pContextCallback: (context) {
          if (_loadingCommandAmount == 0) {
            Navigator.pop(context);
          } else {
            _dialogContext = context;
          }
        },
      );
    }
    _loadingCommandAmount++;
  }

  void _closeLoadingProgress() {
    _loadingCommandAmount--;
    log("closeLoadingProgress | $_loadingCommandAmount");
    if (_loadingCommandAmount == 0 && _dialogContext != null) {
      Navigator.pop(_dialogContext!);
      _dialogContext = null;
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

    if (pCommand is ApiCommand) {
      // if (pCommand is StartupCommand ||
      //     pCommand is LoginCommand ||
      //     pCommand is LogoutCommand ||
      //     pCommand is ChangePasswordCommand ||
      //     pCommand is DeviceStatusCommand ||
      //     pCommand is DownloadImagesCommand ||
      //     pCommand is DownloadStyleCommand ||
      //     pCommand is DownloadTranslationCommand ||
      //     pCommand is ResetPasswordCommand) {
      //   return false;
      // }
      if (pCommand is DeleteRecordCommand ||
          pCommand is FetchCommand ||
          pCommand is FilterCommand ||
          pCommand is InsertRecordCommand ||
          pCommand is PressButtonCommand ||
          pCommand is SelectRecordCommand ||
          pCommand is SetValueCommand ||
          pCommand is SetValuesCommand) {
        return true;
      }
    }

    return false;
  }

  Duration durationForCommand(BaseCommand pCommand) {
    return const Duration(milliseconds: 250);
  }
}
