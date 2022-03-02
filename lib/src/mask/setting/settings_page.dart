import 'dart:developer';

import 'package:flutter/material.dart';
import '../../mixin/ui_service_mixin.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with UiServiceMixin {
  void loginCodeScanned(dynamic data) {
    log("arrived");
    uiService.closeQRScanner();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
        ),
        body: ElevatedButton(
          child: Text("OPEN QR"),
          onPressed: () {
            uiService.openQRScanner(callback: loginCodeScanned);
          },
        ));
  }
}
