import 'package:flutter/material.dart';

import '../../../util/translation/app_localizations.dart';
import '../../util/restart_widget.dart';

showRestartDialog(BuildContext context, String title, String message) async {
  await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.text('$title')),
          content: Text(AppLocalizations.of(context)!.text('$message')),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context)!.text('Ok'))),
          ],
        );
      }).then((_) => RestartWidget.restart(context));
}
