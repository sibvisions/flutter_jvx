import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'application_widget.dart';
import 'util/config/dev_config.dart';

/// This widget is a wraps the [ApplicationWidget] with a [FutureBuilder]
/// to load the [DevConfig]
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
    if (kReleaseMode) {
      return ApplicationWidget();
    }

    return FutureBuilder<DevConfig>(
        future: _configFuture,
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
        });
  }
}
