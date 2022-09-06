import 'package:flutter/material.dart';

import '../../../main.dart';
import '../../../mixin/config_service_mixin.dart';
import '../../../mixin/ui_service_mixin.dart';
import '../../model/command/api/startup_command.dart';
import '../../model/command/ui/view/message/open_session_expired_dialog_command.dart';

class ServerSessionExpired extends StatelessWidget with UiServiceGetterMixin, ConfigServiceGetterMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final OpenSessionExpiredDialogCommand command;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ServerSessionExpired({
    required this.command,
    Key? key,
  }) : super(key: key);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).cardColor.withAlpha(255),
      title: Text(command.title.isNotEmpty ? command.title : FlutterJVx.translate("Session Expired")),
      content: Text(command.message!),
      actions: [
        TextButton(
          onPressed: () => _restartApp(context: context),
          child: Text(
            FlutterJVx.translate("Restart App"),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void _restartApp({required BuildContext context}) {
    StartupCommand startupCommand = StartupCommand(
      reason: "Session expired dialog",
      username: getConfigService().getUsername(),
      password: getConfigService().getPassword(),
    );
    getUiService().sendCommand(startupCommand);

    //close popup
    Navigator.of(context).pop();
  }
}
