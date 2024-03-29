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
