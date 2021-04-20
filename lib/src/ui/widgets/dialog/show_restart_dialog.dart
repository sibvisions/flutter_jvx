import 'package:flutter/material.dart';

import '../../../util/translation/app_localizations.dart';
import '../../util/restart_widget.dart';

showRestartDialog(BuildContext context, String info) async {
  await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.text('Restarting App')),
          content: Text(AppLocalizations.of(context)!.text('$info')),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context)!.text('OK'))),
          ],
        );
      }).then((_) => RestartWidget.restart(context));
}
