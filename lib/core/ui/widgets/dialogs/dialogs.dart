import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/core/models/app/settings_arguments.dart';
import 'package:jvx_flutterclient/core/services/local/local_database/i_offline_database_provider.dart';
import 'package:jvx_flutterclient/core/services/local/local_database/offline_database.dart';
import 'package:jvx_flutterclient/core/ui/pages/settings_page.dart';
import 'package:jvx_flutterclient/core/ui/widgets/builder/custom_stateful_builder.dart';
import 'package:jvx_flutterclient/core/utils/theme/theme_manager.dart';
import 'package:jvx_flutterclient/injection_container.dart';

import '../../../utils/translation/app_localizations.dart';
import '../util/restart_widget.dart';

showGoToSettings(BuildContext context, String title, String message) async {
  if (title == null) title = "Missing title";
  if (message == null) message = "";

  await showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: <Widget>[
              !kIsWeb
                  ? FlatButton(
                      child: Text(AppLocalizations.of(context).text('Close')),
                      onPressed: () => exit(0),
                    )
                  : Container(),
              FlatButton(
                child: Text(AppLocalizations.of(context).text('To Settings')),
                onPressed: () => Navigator.of(context).pushReplacementNamed(
                    SettingsPage.route,
                    arguments: "error.dialog"),
              )
            ],
          ));
}

showError(BuildContext context, String title, String message) async {
  if (title == null) title = "Missing title";
  if (message == null) message = "";

  await showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: <Widget>[
              FlatButton(
                child: Text(AppLocalizations.of(context).text('Close')),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ));
}

showSessionExpired(BuildContext context, String title, String message) async {
  if (title == null) title = "Missing title";
  if (message == null) message = "";

  await showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: <Widget>[
              FlatButton(
                  child: Text(AppLocalizations.of(context).text('OK')),
                  onPressed: () {
                    Navigator.of(context).pop();
                  })
            ],
          )).then((val) {
    RestartWidget.restartApp(context);
  });
}

showRestart(BuildContext context, String title, String message) async {
  if (title == null) title = "Missing title";
  if (message == null) message = "";

  await showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: <Widget>[
              FlatButton(
                  child: Text(AppLocalizations.of(context).text('OK')),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              FlatButton(
                  child:
                      Text(AppLocalizations.of(context).text('Go to settings')),
                  onPressed: () {
                    Navigator.of(context).pushNamed(SettingsPage.route);
                  }),
            ],
          )).then((val) {
    RestartWidget.restartApp(context);
  });
}

showSuccess(BuildContext context, String message, IconData icon) {
  if (message == null) message = "";
  showDialog(
      context: context,
      builder: (context) => Center(
            child: Material(
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.black,
              elevation: 5.0,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(icon, color: Colors.green),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      message,
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
              ),
            ),
          ));
}

showProgress(BuildContext context, [String loadingText]) {
  showDialog(
      routeSettings: RouteSettings(name: '/loading'),
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
            onWillPop: () async => false,
            child: Opacity(
              opacity: 0.7,
              child: Container(
                child: Center(
                    child: Container(
                  width: 100,
                  height: 100,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      CircularProgressIndicator(backgroundColor: Colors.white),
                    ],
                  ),
                )),
              ),
            ),
          ));
}

hideProgress(BuildContext context) {
  Navigator.of(context).pop();
}

showLinearProgressIndicator(BuildContext context) {
  double _progress = 0;

  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
            onWillPop: () async => false,
            child: CustomStatefulBuilder(
              builder: (context, setState) {
                (sl<IOfflineDatabaseProvider>() as OfflineDatabase)
                    .addProgressCallback(
                        (val) => setState(() => _progress = val));

                return Material(
                  color: Colors.white,
                  child: Opacity(
                    opacity: 0.7,
                    child: Container(
                      child: Center(
                          child: Container(
                        width: 200,
                        height: 200,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withAlpha(33),
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text(
                                AppLocalizations.of(context)
                                        .text('Gehe offline...') +
                                    ' ${(_progress * 100).round()}%',
                                style: TextStyle(fontSize: 16),
                              ),
                              LinearProgressIndicator(
                                value: _progress,
                              )
                            ],
                          ),
                        ),
                      )),
                    ),
                  ),
                );
              },
              dispose: () => (sl<IOfflineDatabaseProvider>() as OfflineDatabase)
                  .removeAllProgressCallbacks(),
            ),
          ));
}

hideLinearProgressIndicator(BuildContext context) {
  Navigator.of(context).pop();
}

showTextInputDialog(BuildContext context, String title, String textLabel,
    String textHint, initialVal, void onTapCallback(String val)) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _controller =
            new TextEditingController(text: initialVal);
        return Theme(
          data: sl<ThemeManager>().themeData,
          child: AlertDialog(
            title: Text(title),
            content: Form(
              child: new TextField(
                controller: _controller,
                style: new TextStyle(fontSize: 15.0, color: Colors.black),
                decoration: new InputDecoration(
                    hintText: textHint,
                    labelText: textLabel,
                    labelStyle: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text(AppLocalizations.of(context).text('Close')),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text(AppLocalizations.of(context).text('OK')),
                onPressed: () {
                  onTapCallback(_controller.text);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      });
}

showSyncDialog(BuildContext context) {
  return showDialog(
      context: context,
      builder: (context) {
        return Theme(
          data: sl<ThemeManager>().themeData,
          child: AlertDialog(
            title: Text(AppLocalizations.of(context).text(
                'Wollen Sie in den Online Modus wechseln und alle Änderungen synchronisieren?')),
            actions: [
              new FlatButton(
                child: Text(AppLocalizations.of(context).text('Ja')),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
              new FlatButton(
                child: Text(AppLocalizations.of(context).text('Nein')),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
            ],
          ),
        );
      });
}
