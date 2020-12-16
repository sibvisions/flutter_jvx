import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef Widget LoadConfigBuilder(bool shouldLoadConfig);

class RestartWidget extends StatefulWidget {
  final LoadConfigBuilder loadConfigBuilder;

  const RestartWidget({Key key, this.loadConfigBuilder}) : super(key: key);

  @override
  _RestartWidgetState createState() => _RestartWidgetState();

  static restartApp(BuildContext context, {bool shouldLoadConfig = false}) {
    final _RestartWidgetState state =
        context.findAncestorStateOfType<_RestartWidgetState>();

    state._restartApp(shouldLoadConfig);
  }
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = new UniqueKey();
  bool shouldLoadConfig = true;

  void _restartApp(bool shouldLoadConfig) {
    this.shouldLoadConfig = shouldLoadConfig;
    this.setState(() {
      key = new UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: key,
      child: widget.loadConfigBuilder(
          (this.shouldLoadConfig == null || this.shouldLoadConfig)
              ? true
              : false),
    );
  }
}
