import 'package:flutter/material.dart';

import '../../flutter_ui.dart';
import '../../model/command/ui/view/message/open_session_expired_dialog_command.dart';
import '../../service/ui/i_ui_service.dart';
import '../frame_dialog.dart';

class ServerSessionExpired extends FrameDialog {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final OpenSessionExpiredDialogCommand command;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const ServerSessionExpired({
    super.key,
    required this.command,
    super.dismissible,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(command.title?.isNotEmpty == true ? command.title! : FlutterUI.translate("Session Expired")),
      content:
          Text(command.message?.isNotEmpty == true ? command.message! : FlutterUI.translate("Session has expired")),
      actions: [
        TextButton(
          onPressed: () => _restartApp(),
          child: Text(
            FlutterUI.translate("Restart App"),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void _restartApp() {
    IUiService().closeFrameDialog(this);
    FlutterUIState.of(FlutterUI.getCurrentContext())?.restart();
  }
}
