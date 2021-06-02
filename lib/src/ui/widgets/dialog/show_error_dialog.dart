import 'package:flutter/material.dart';

import '../../../models/api/errors/failure.dart';
import '../../../util/translation/app_localizations.dart';

showErrorDialog(BuildContext context, Failure failure) async {
  await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.text('${failure.title}')),
          content:
              Text(AppLocalizations.of(context)!.text('${failure.message}')),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context)!.text('Close'))),
          ],
        );
      });
}
