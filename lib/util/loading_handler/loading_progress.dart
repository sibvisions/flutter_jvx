import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/service/service.dart';
import 'package:flutter_client/src/service/ui/i_ui_service.dart';
import 'package:flutter_client/util/loading_handler/i_command_progress_handler.dart';

/// The [DefaultLoadingProgressHandler] shows a loading progress if a request is over its defined threshold for the wait time.
class DefaultLoadingProgressHandler implements ICommandProgressHandler {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Map of all timers for every call.
  final Map<BaseCommand, Timer> _commandTimerMap = {};

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
      Duration duration = durationForCommand(pCommand);
      _commandTimerMap[pCommand] = Timer(duration, _showLoadingProgress);
    }
  }

  @override
  void notifyCommandProgressEnd(BaseCommand pCommand) async {
    Timer? timer = _commandTimerMap.remove(pCommand);
    if (timer != null) {
      log("found timer");
      if (timer.isActive) {
        timer.cancel();
        log("cancel timer");
      } else {
        _closeLoadingProgress();
      }
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void _showLoadingProgress() {
    if (_loadingCommandAmount == 0) {
      log("showLoadingProgress | $_loadingCommandAmount");
      services<IUiService>().openDialog(
        pDialogWidget: _createLoadingProgressIndicator(),
        pIsDismissible: false,
        pContextCallback: (context) {
          log("set context | $_loadingCommandAmount");
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
    if (_loadingCommandAmount == 0 && _dialogContext != null) {
      log("closeLoadingProgress | $_loadingCommandAmount");

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
    return true;
  }

  Duration durationForCommand(BaseCommand pCommand) {
    return const Duration(milliseconds: 250);
  }
}
