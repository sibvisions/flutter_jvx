import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/model/properties/properties.dart';
import 'package:jvx_mobile_v3/ui/tools/restart.dart';
import 'package:jvx_mobile_v3/utils/translations.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

showGoToSettings(BuildContext context, String title, String message) {
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: <Widget>[
              FlatButton(
                child: Text(Translations.of(context).text2('Close')),
                onPressed: () => exit(0),
              ),
              FlatButton(
                child: Text(Translations.of(context).text2('To Settings')),
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed('/settings'),
              )
            ],
          ));
}

showError(BuildContext context, String title, String message) {
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text(Properties.utf8convert(title)),
            content: Text(Properties.utf8convert(message)),
            actions: <Widget>[
              FlatButton(
                child: Text(Translations.of(context).text2('Close', 'Close')),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ));
}

showSessionExpired(BuildContext context, String title, String message) async {
  await showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          )).then((val) {
    RestartWidget.restartApp(context);
  });
}

showSuccess(BuildContext context, String message, IconData icon) {
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
                      style: TextStyle(
                          fontFamily: UIData.ralewayFont, color: Colors.white),
                    )
                  ],
                ),
              ),
            ),
          ));
}

showProgress(BuildContext context, [String loadingText]) {
  if (!globals.isLoading) {
    globals.isLoading = true;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Container(
              width: 100,
              height: 100,
              child: Center(
                child: Opacity(
                  opacity: 0.7,
                  child: Material(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CircularProgressIndicator(
                            backgroundColor: Colors.white,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            loadingText ?? 'Loading...',
                            style: TextStyle(fontSize: 12, color: Colors.black),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ));

    print("Show Progress!");
  }
}

hideProgress(BuildContext context) {
  if (globals.isLoading) {
    globals.isLoading = false;
    Navigator.of(context).pop();
    print("Hide Progress!");
  }
}

showTextInputDialog(BuildContext context, String title, String textLabel,
    String textHint, initialVal, void onTapCallback(String val)) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _controller =
            new TextEditingController(text: initialVal);
        return AlertDialog(
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
              textColor: UIData.ui_kit_color_2,
              child: new Text("CLOSE"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              textColor: UIData.ui_kit_color_2,
              child: new Text("OK"),
              onPressed: () {
                onTapCallback(_controller.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
}
