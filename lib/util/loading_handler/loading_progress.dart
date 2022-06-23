import 'package:flutter/material.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/service/service.dart';
import 'package:flutter_client/src/service/ui/i_ui_service.dart';
import 'package:flutter_client/util/loading_handler/i_command_progress_handler.dart';

class DefaultLoadingProgressHandler implements ICommandProgressHandler {
  Map<BaseCommand, Future> commandFutureMap = {};
  BuildContext? _lastContext;
  int amount = 0;

  void showLoadingProgress() {
    if (_lastContext == null && amount == 0) {
      services<IUiService>().openDialog(
        pDialogWidget: _createLoadingProgressIndicator(),
        pIsDismissible: false,
        pContextCallback: (context) => _lastContext = context,
      );
    }
    amount++;
  }

  void closeLoadingProgress() {
    if (_lastContext != null) {
      if (amount > 1) {
        amount--;
      } else {
        Navigator.pop(_lastContext!);
      }
    }
  }

  Widget _createLoadingProgressIndicator() {
    return const Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: 25.0,
        height: 25.0,
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }

  @override
  void notifyCommandProgressEnd(BaseCommand pCommand) {
    // if (isSupported(pCommand)) {
    //   Duration duration = durationForCommand(pCommand);
    //   commandFutureMap[pCommand] = Future.delayed(duration, () => showLoadingProgress());
    // }
  }

  @override
  void notifyCommandProgressStart(BaseCommand pCommand) {
    // Future? future = commandFutureMap[pCommand];
    // if (future != null) {
    //   future.whenComplete(() => null);
    // }
  }

  bool isSupported(BaseCommand pCommand) {
    return true;
  }

  Duration durationForCommand(BaseCommand pCommand) {
    return const Duration(seconds: 2);
  }
}
