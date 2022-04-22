import 'package:flutter/material.dart';
import 'package:flutter_client/src/mixin/ui_service_mixin.dart';
import 'package:flutter_client/src/model/command/api/startup_command.dart';

class ServerSessionExpired extends StatelessWidget with UiServiceMixin {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final String message;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ServerSessionExpired({
    required this.message,
    Key? key
  }) : super(key: key);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).cardColor.withAlpha(255),
      title: const Text("SESSION EXPIRED"),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => _restartApp(context: context),
          child: const Text(
            "RESTART APP",
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold
            ),
          ),

        ),
      ],
    );
  }
  
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void _restartApp ({required BuildContext context}) {
    StartupCommand startupCommand = StartupCommand(
        reason: "Session expired dialog"
    );
    uiService.sendCommand(startupCommand);
    
    //close popup
    Navigator.of(context).pop();
  }

}
