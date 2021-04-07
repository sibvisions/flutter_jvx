import 'package:flutter/material.dart';

import '../../../services/remote/cubit/api_cubit.dart';
import '../../../util/translation/app_localizations.dart';
import '../../util/restart_widget.dart';

showSessionExpiredDialog(BuildContext context, ApiError error) async {
  await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.text('${error.failure.title}')),
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