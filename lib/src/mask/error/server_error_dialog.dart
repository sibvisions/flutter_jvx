import 'package:flutter/material.dart';

import '../../../main.dart';
import '../../../mixin/config_service_mixin.dart';
import '../../model/command/ui/view/message/open_error_dialog_command.dart';

/// This is a standard template for a server side error message.
class ServerErrorDialog extends StatelessWidget with ConfigServiceGetterMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final OpenErrorDialogCommand command;

  /// True if this error is fixable by the user (e.g. invalid url/timeout)
  final bool goToSettings;

  /// True if this dialog can be dismissed via button
  final bool dismissible;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ServerErrorDialog({
    required this.command,
    this.goToSettings = false,
    this.dismissible = false,
    Key? key,
  }) : super(key: key);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).cardColor.withAlpha(255),
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
            Navigator.of(context).pop();
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
          onPressed: () => Navigator.of(context).pop(),
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
