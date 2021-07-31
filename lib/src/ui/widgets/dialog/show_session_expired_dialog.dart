import 'package:flutter/material.dart';

import '../../../models/api/errors/failure.dart';

import '../../../util/translation/app_localizations.dart';
import '../../util/restart_widget.dart';

showSessionExpiredDialog(BuildContext context, Failure failure) async {
  await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.text('${failure.title}')),
          content:
              Text(AppLocalizations.of(context)!.text('The App will restart.')),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context)!.text('Ok'))),
          ],
        );
      }).then((_) => RestartWidget.restart(context));
}
