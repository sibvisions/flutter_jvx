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

import '../../../flutter_jvx.dart';
import '../apps/app_overview_page.dart';
import '../jvx_dialog.dart';
import 'ierror.dart';

/// This is a standard template for a server side error message.
class ServerErrorDialog extends StatelessWidget with JVxDialog implements IError {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final OpenServerErrorDialogCommand command;

  /// True if this error is fixable by the user (e.g. invalid url/timeout)
  final bool goToAppOverview;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ServerErrorDialog({
    super.key,
    required this.command,
    this.goToAppOverview = false,
  }) {
    dismissible = true;
    modal = true;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {

    List<Widget>? actions = _getButtons(context);

    if (actions.isEmpty) {
      //avoid padding, doesn't work with an empty list!
      actions = null;
    }

    Widget? content;

    if (command.message != null && command.message!.isNotEmpty) {
      content = IntrinsicHeight(
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Padding(
                    padding: EdgeInsets.only(right: 15),
                    child: Icon(
                        Icons.report_gmailerrorred_rounded,
                        size: JVxColors.MESSAGE_ICON_SIZE
                    )
                ),
                Flexible(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Text(command.message!)]
                    )
                )
              ]
          )
      );
    }

    return AlertDialog(
      contentPadding: actions == null ? const EdgeInsets.all(24) : null,
      actionsPadding: JVxColors.ALERTDIALOG_ACTION_PADDING,
      title: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text((command.title?.isNotEmpty ?? false) ? command.title! : FlutterUI.translate("Server Error"))
      ),
      scrollable: true,
      content: content,
      actions: actions,
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Get all possible actions
  List<Widget> _getButtons(BuildContext context) {
    List<Widget> actions = [];

    if (goToAppOverview && IUiService().canRouteToAppOverview()) {
      actions.add(
        TextButton.icon(
          onPressed: () {
            IUiService().closeJVxDialog(this);
            IUiService().routeToAppOverview();
          },
          icon: const Icon(AppOverviewPage.appsIcon),
          label: Text(
            AppOverviewPage.appsOrAppText,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    if (dismissible) {
      actions.add(
        TextButton(
          onPressed: () {
            IUiService().closeJVxDialog(this);
          },
          child: Text(
            FlutterUI.translate("OK"),
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
      ICommandService().sendCommand(
        CloseFrameCommand(frameName: command.componentId!, reason: "Server Error Dialog was dismissed"),
      );
    }
  }
}
