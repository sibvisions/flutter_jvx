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
import '../../flutter_ui.dart';
import '../../service/ui/i_ui_service.dart';
import '../apps/app_overview_page.dart';
import '../jvx_dialog.dart';
import 'ierror.dart';

/// This is a standard template for an error message.
class ErrorDialog extends StatelessWidget with JVxDialog implements IError {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// This title will be displayed in the popup
  final String? title;

  /// This message will be displayed in the popup
  final String message;

  /// True if this error is fixable by the user (e.g. invalid url/timeout)
  final bool goToAppOverview;

  /// True if a retry is possible
  final bool retry;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ErrorDialog({
    super.key,
    required this.message,
    this.title,
    this.goToAppOverview = false,
    this.retry = false,
    dismissible,
  }) {
    this.dismissible = dismissible;
    modal = true;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsPadding: JVxColors.ALERTDIALOG_ACTION_PADDING,
      title: Text(title?.isNotEmpty == true ? title! : FlutterUI.translate("Error")),
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
          onPressed: () {
            IUiService().closeJVxDialog(this);
          },
          child: Text(
            FlutterUI.translate("Retry"),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

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
}
