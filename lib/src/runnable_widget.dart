import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'application_widget.dart';
import 'util/config/dev_config.dart';

class RunnableWidget extends StatefulWidget {
  @override
  _RunnableWidgetState createState() => _RunnableWidgetState();
}

class _RunnableWidgetState extends State<RunnableWidget> {
  late Future<DevConfig> _configFuture;

  @override
  void initState() {
    super.initState();

    _configFuture = DevConfig.loadConfig(path: 'assets/env/dev.conf.json');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DevConfig>(
        future: _configFuture,
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
              devConfig: prod ? null : snapshot.data,
            );
          } else {
            return Container();
          }
        });
  }
}
