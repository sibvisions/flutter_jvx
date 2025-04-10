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
import '../jvx_dialog.dart';
import 'ierror.dart';

class ServerSessionExpiredDialog extends StatelessWidget with JVxDialog implements IError {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final OpenSessionExpiredDialogCommand command;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ServerSessionExpiredDialog({
    super.key,
    required this.command,
    bool? dismissible,
  }) {
    this.dismissible = dismissible == true;
    modal = true;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {

    Widget content = IntrinsicHeight(
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
              children: [Text(FlutterUI.translate(command.message?.isNotEmpty == true ? command.message! : "Session has expired"))]
            )
          )
        ]
      )
    );

    // We have to translate the server response because it will always be in english
    // as the server has no session and therefore no translation.
    return AlertDialog(
      contentPadding: const EdgeInsets.all(24),
      actionsPadding: JVxColors.ALERTDIALOG_ACTION_PADDING,
      title: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(FlutterUI.translate(command.title?.isNotEmpty == true ? command.title! : "Session Expired"))
      ),
      scrollable: true,
      content: content,
      actions: [
        TextButton(
          onPressed: _close,
          child: Text(
            FlutterUI.translate("Cancel"),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        TextButton(
          onPressed: _restartApp,
          child: Text(
            FlutterUI.translate("Restart App"),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void _close() {
    IApiService().getRepository().cancelledSessionExpired.value = true;
    IUiService().closeJVxDialog(this);
  }

  void _restartApp() {
    IUiService().closeJVxDialog(this);
    IAppService().startApp();
  }
}
