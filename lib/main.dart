import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutterclient/src/services/remote/rest/cert_http_overrides.dart';

import 'injection_container.dart' as di;
import 'src/application_widget.dart';
import 'src/util/config/dev_config.dart';

void main() async {
  HttpOverrides.global = CertHttpOverrides();

  WidgetsFlutterBinding.ensureInitialized();

  await di.init();

  runApp(FutureBuilder<DevConfig>(
      future: DevConfig.loadConfig(path: 'assets/env/dev.conf.json'),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ApplicationWidget();
        }

        const prod = bool.fromEnvironment('PROD', defaultValue: false);

        if (snapshot.hasData) {
          return ApplicationWidget(
            devConfig: prod ? null : snapshot.data,
          );
        } else {
          return Container();
        }
      }));
}
