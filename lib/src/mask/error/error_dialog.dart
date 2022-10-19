import 'package:flutter/material.dart';

import '../../../flutter_jvx.dart';
import '../../../services.dart';
import '../frame_dialog.dart';

/// This is a standard template for an error message.
class ErrorDialog extends FrameDialog {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// This title will be displayed in the popup
  final String? title;

  /// This message will be displayed in the popup
  final String message;

  /// True if this error is fixable by the user (e.g. invalid url/timeout)
  final bool goToSettings;

  /// True if a retry is possible
  final bool retry;

  /// True if a no action (OK) button should be displayed
  final bool dismissibleViaButton;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const ErrorDialog({
    required this.message,
    this.title,
    this.goToSettings = false,
    this.dismissibleViaButton = true,
    this.retry = false,
    super.dismissible,
    super.key,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title?.isNotEmpty == true ? title! : FlutterJVx.translate("Error")),
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
          onPressed: () => IUiService().closeFrameDialog(this),
          child: Text(
            FlutterJVx.translate("Retry"),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    if (goToSettings) {
      actions.add(
        TextButton(
          onPressed: () {
            IUiService().closeFrameDialog(this);
            IUiService().routeToSettings(pReplaceRoute: true);
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
