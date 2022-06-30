import 'package:flutter/material.dart';
import 'package:flutter_client/main.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:flutter_client/src/mixin/ui_service_mixin.dart';
import 'package:flutter_client/src/model/command/api/close_frame_command.dart';

/// This is a standard template for a server side message.
class ServerDialog extends StatelessWidget with ConfigServiceMixin, UiServiceMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// This message will be displayed in the popup
  final String message;

  /// Name of the message screen used for closing the message
  final String messageScreenName;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ServerDialog({
    required this.messageScreenName,
    required this.message,
    Key? key,
  }) : super(key: key);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: themeData.cardColor.withAlpha(255),
      title: Text(configService.translateText("MESSAGE")),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => _closeScreen(context),
          child: Text(
            configService.translateText("OK"),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  _closeScreen(BuildContext context) {
    CloseFrameCommand closeScreenCommand = CloseFrameCommand(frameName: messageScreenName, reason: "Message Dialog was dismissed");
    uiService.sendCommand(closeScreenCommand);

    Navigator.of(context).pop();
  }
}
