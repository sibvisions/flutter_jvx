import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'injection_container.dart' as di;
import 'src/application_widget.dart';
import 'src/services/remote/rest/cert_http_overrides.dart';
import 'src/util/config/dev_config.dart';

void main() async {
  HttpOverrides.global = CertHttpOverrides();

  WidgetsFlutterBinding.ensureInitialized();

  await di.init();

  runApp(_getRunnableWidget());
}

Widget _getRunnableWidget() {
  return FutureBuilder<DevConfig>(
      future: DevConfig.loadConfig(path: 'assets/env/dev.conf.json'),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ApplicationWidget();
        }

        late bool prod;

        if (!kIsWeb) {
          prod = bool.fromEnvironment('PROD', defaultValue: false);
        } else {
          prod = true;
        }

        if (snapshot.hasData) {
          return ApplicationWidget(
            devConfig: null, // prod ? null : snapshot.data,
          );
        } else {
          return Container();
        }
      });
}
