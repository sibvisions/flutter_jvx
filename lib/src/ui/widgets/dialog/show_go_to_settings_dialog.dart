import 'package:flutter/material.dart';

import '../../../models/state/routes/routes.dart';
import '../../../services/remote/cubit/api_cubit.dart';
import '../../../util/translation/app_localizations.dart';

showGoToSettingsDialog(BuildContext context, ApiError error) async {
  await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
              AppLocalizations.of(context)!.text('${error.failure.title}')),
          content: Text(
              AppLocalizations.of(context)!.text('${error.failure.message}')),
          actions: [
            TextButton(
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed(Routes.settings),
                child: Text(AppLocalizations.of(context)!.text('To Settings'))),
          ],
        );
      });
}
