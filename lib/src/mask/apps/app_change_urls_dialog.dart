/*
 * Copyright 2023 SIB Visions GmbH
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
import '../../service/apps/app.dart';

class AppChangeUrlsDialog extends StatefulWidget {
  final String oldHost;
  final String newHost;
  final List<App> appsToChange;

  const AppChangeUrlsDialog({
    super.key,
    required this.oldHost,
    required this.newHost,
    required this.appsToChange,
  });

  @override
  State<AppChangeUrlsDialog> createState() => _AppChangeUrlsDialogState();
}

class _AppChangeUrlsDialogState extends State<AppChangeUrlsDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(FlutterUI.translateLocal("Change other apps?")),
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8, right: 16),
            child: Text(
                "${FlutterUI.translateLocal("Changes apps from")} '${widget.oldHost}' ${FlutterUI.translateLocal("to")} '${widget.newHost}'"),
          ),
          Flexible(
            child: SingleChildScrollView(
              child: ExpansionTile(
                tilePadding: const EdgeInsets.only(left: 16, right: 16),
                childrenPadding: const EdgeInsets.only(left: 8),
                title: Text(FlutterUI.translateLocal("Affected apps")),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...widget.appsToChange.map(
                    (e) => ListTile(title: Text(e.effectiveTitle!)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actionsPadding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 12.0),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(FlutterUI.translateLocal("No")),
        ),
        TextButton(
          onPressed: () {
            for (App appToChange in widget.appsToChange) {
              appToChange.updateBaseUrl(appToChange.baseUrl!.replace(host: widget.newHost));
            }
            Navigator.pop(context);
          },
          child: Text(FlutterUI.translateLocal("Yes")),
        )
      ],
    );
  }
}
