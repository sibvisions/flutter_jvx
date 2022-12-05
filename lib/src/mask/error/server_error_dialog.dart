import 'package:flutter/material.dart';

import '../../flutter_ui.dart';
import '../../model/command/api/close_frame_command.dart';
import '../../model/command/ui/view/message/open_server_error_dialog_command.dart';
import '../../service/ui/i_ui_service.dart';
import '../frame_dialog.dart';

/// This is a standard template for a server side error message.
class ServerErrorDialog extends FrameDialog {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final OpenServerErrorDialogCommand command;

  /// True if this error is fixable by the user (e.g. invalid url/timeout)
  final bool goToSettings;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const ServerErrorDialog({
    super.key,
    required this.command,
    this.goToSettings = false,
  }) : super(dismissible: true);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text((command.title?.isNotEmpty ?? false) ? command.title! : FlutterUI.translate("Server Error")),
      content: Text(command.message!),
      actions: _getButtons(context),
    );
  }

  @override
  void onClose() {
    if (command.componentId != null) {
      IUiService().sendCommand(
        CloseFrameCommand(frameName: command.componentId!, reason: "Server Error Dialog was dismissed"),
      );
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Get all possible actions
  List<Widget> _getButtons(BuildContext context) {
    List<Widget> actions = [];

    if (goToSettings) {
      actions.add(
        TextButton(
          onPressed: () {
            IUiService().closeFrameDialog(this);
            IUiService().routeToSettings(pReplaceRoute: true);
          },
          child: Text(
            FlutterUI.translate("Go to Settings"),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    if (dismissible) {
      actions.add(
        TextButton(
          onPressed: () {
            IUiService().closeFrameDialog(this);
          },
          child: Text(
            FlutterUI.translate("Ok"),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return actions;
  }
}
