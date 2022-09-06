import 'package:flutter/material.dart';

import '../../../main.dart';
import '../../../mixin/config_service_mixin.dart';

/// This is a standard template for a server side error message.
class ErrorDialog extends StatelessWidget with ConfigServiceGetterMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// This title will be displayed in the popup
  final String? title;

  /// This message will be displayed in the popup
  final String message;

  /// True if this error is fixable by the user (e.g. invalid url/timeout)
  final bool gotToSettings;

  /// True if a retry is possible
  final bool retry;

  /// True if a no action (OK) button should be displayed
  final bool dismissible;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ErrorDialog({
    required this.message,
    this.title,
    this.gotToSettings = false,
    this.dismissible = true,
    this.retry = false,
    super.key,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).cardColor.withAlpha(255),
      title: Text(title ?? FlutterJVx.translate("Error")),
      content: Text(message),
      actions: _getActions(context),
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Get all possible actions
  List<Widget> _getActions(BuildContext context) {
    List<Widget> actions = [];

    if (retry) {
      actions.add(
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            FlutterJVx.translate("Retry"),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    if (gotToSettings) {
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
