import 'package:flutter/material.dart';
import 'package:flutter_client/src/service/service.dart';
import 'package:flutter_client/src/service/ui/i_ui_service.dart';

class LoadingProgress {
  static BuildContext? _lastContext;
  static int amount = 0;

  static void showLoadingProgress() {
    if (_lastContext == null && amount == 0) {
      services<IUiService>().openDialog(
        pDialogWidget: _createLoadingProgressIndicator(),
        pIsDismissible: false,
        pContextCallback: (context) => _lastContext = context,
      );
    }
    amount++;
  }

  static void closeLoadingProgress() {
    if (_lastContext != null) {
      if (amount > 1) {
        amount--;
      } else {
        Navigator.pop(_lastContext!);
      }
    }
  }

  static Widget _createLoadingProgressIndicator() {
    return const Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: 25.0,
        height: 25.0,
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }
}
