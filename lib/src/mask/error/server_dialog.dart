import 'package:flutter/material.dart';

import '../../../mixin/config_service_mixin.dart';
import '../../../mixin/ui_service_mixin.dart';
import '../../model/command/api/close_frame_command.dart';

/// This is a standard template for a server side message.
class ServerDialog extends StatelessWidget with ConfigServiceGetterMixin, UiServiceGetterMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// This message will be displayed in the popup
  final String message;

  /// Name of the message screen used for closing the message
  final String componentId;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ServerDialog({
    required this.componentId,
    required this.message,
    Key? key,
  }) : super(key: key);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).cardColor.withAlpha(255),
      title: Text(getConfigService().translateText("MESSAGE")),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => _closeScreen(context),
          child: Text(
            getConfigService().translateText("OK"),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  _closeScreen(BuildContext context) {
    CloseFrameCommand closeScreenCommand =
        CloseFrameCommand(frameName: componentId, reason: "Message Dialog was dismissed");
    getUiService().sendCommand(closeScreenCommand);

    Navigator.of(context).pop();
  }
}
