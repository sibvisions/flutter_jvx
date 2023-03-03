/* 
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'package:flutter/material.dart';

import '../../flutter_ui.dart';
import '../../model/command/api/close_frame_command.dart';
import '../../model/command/ui/view/message/open_server_error_dialog_command.dart';
import '../../service/ui/i_ui_service.dart';
import '../frame_dialog.dart';

/// This is a standard template for a server side error message.
class ServerErrorDialog extends JVxDialog {
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
            onClose();
            IUiService().closeJVxDialog(this);
            IUiService().routeToAppOverview();
          },
          child: Text(
            FlutterUI.translate("Go to Apps"),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    if (dismissible) {
      actions.add(
        TextButton(
          onPressed: () {
            onClose();
            IUiService().closeJVxDialog(this);
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

  @override
  void onClose() {
    if (command.componentId != null) {
      IUiService().sendCommand(
        CloseFrameCommand(frameName: command.componentId!, reason: "Server Error Dialog was dismissed"),
      );
    }
  }
}
