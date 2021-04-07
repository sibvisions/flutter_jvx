import 'package:flutter/material.dart';
import 'package:flutterclient/src/util/theme/theme_manager.dart';
import 'package:flutterclient/src/util/translation/app_localizations.dart';

import '../../../../../../injection_container.dart';

showSyncDialog(BuildContext context) {
  return showDialog(
      context: context,
      builder: (context) {
        return Theme(
          data: sl<ThemeManager>().value,
          child: AlertDialog(
            title: Text(AppLocalizations.of(context)!.text(
                'Wollen Sie in den Online Modus wechseln und alle Änderungen synchronisieren?')),
            actions: [
              new ElevatedButton(
                child: Text(AppLocalizations.of(context)!.text('Ja')),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
              new ElevatedButton(
                child: Text(AppLocalizations.of(context)!.text('Nein')),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
            ],
          ),
        );
      });
}
