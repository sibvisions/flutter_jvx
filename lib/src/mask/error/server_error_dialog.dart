import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

import '../../../flutter_jvx.dart';
import '../../../services.dart';
import '../../model/command/ui/view/message/open_error_dialog_command.dart';
import '../frame_dialog.dart';

/// This is a standard template for a server side error message.
class ServerErrorDialog extends FrameDialog {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final OpenErrorDialogCommand command;

  /// True if this error is fixable by the user (e.g. invalid url/timeout)
  final bool goToSettings;

  /// True if this dialog can be dismissed via button
  final bool closeable;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const ServerErrorDialog({
    required this.command,
    this.goToSettings = false,
    this.closeable = false,
    super.dismissible,
    super.key,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(FlutterJVx.translate(command.title.isNotEmpty ? command.title : "Server Error")),
      content: Text(FlutterJVx.translate(command.message!)),
      actions: _getButtons(context),
    );
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
            context.beamToReplacementNamed("/settings");
          },
          child: Text(
            FlutterJVx.translate("Go to Settings"),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    if (dismissible) {
      actions.add(
        TextButton(
          onPressed: () => IUiService().closeFrameDialog(this),
          child: Text(
            FlutterJVx.translate("Ok"),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return actions;
  }
}
