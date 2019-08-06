import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/services/network_service_response.dart';
import 'package:jvx_mobile_v3/ui/page/settings_page.dart';
import 'package:jvx_mobile_v3/utils/translations.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';

fetchApiResult(BuildContext context, NetworkServiceResponse snapshot) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(Translations.of(context).text('error')),
      content: Text(snapshot.message),
      actions: <Widget>[
        FlatButton(
          child: Text(Translations.of(context).text('close')),
          onPressed: () => exit(0),
        ),
        FlatButton(
          child: Text(Translations.of(context).text('go_to_settings')),
          onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SettingsPage())),
        )
      ],
    )
  );
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
              Icon(
                icon,
                color: Colors.green
              ),
              SizedBox(
                height: 10.0,
              ),
              Text(
                message,
                style: TextStyle(
                  fontFamily: UIData.ralewayFont, color: Colors.white
                ),
              )
            ],
          ),
        ),
      ),
    )
  );
}

showProgress(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Center(
      child: CircularProgressIndicator(
        backgroundColor: Colors.yellow,
      ),
    )
  );
}

hideProgress(BuildContext context) {
  Navigator.pop(context);
}

showTextInputDialog(BuildContext context, String title, String textLabel, String textHint, initialVal, void onTapCallback(String val)) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      TextEditingController _controller = new TextEditingController(text: initialVal);
      return AlertDialog(
        
        title: Text(title),
        content: Form(
          child: new TextField(
            controller: _controller,
            style: new TextStyle(
                fontSize: 15.0, color: Colors.black),
            decoration: new InputDecoration(
                hintText: textHint,
                labelText: textLabel,
                labelStyle:
                    TextStyle(fontWeight: FontWeight.w700)),
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
    }
  );
}