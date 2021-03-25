import 'package:flutter/material.dart';

import 'injection_container.dart' as di;
import 'src/application_widget.dart';
import 'src/util/config/dev_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(FutureBuilder<DevConfig>(
      future: DevConfig.loadConfig(path: 'assets/env/dev.conf.json'),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ApplicationWidget();
        }

        if (snapshot.hasData) {
          return ApplicationWidget(
            devConfig: snapshot.data,
          );
        } else {
          return Container();
        }
      }));
}
