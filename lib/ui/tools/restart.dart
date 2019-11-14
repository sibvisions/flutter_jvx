import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

typedef Widget LoadConfigBuilder(bool loadConf);

class RestartWidget extends StatefulWidget {
  LoadConfigBuilder loadConfigBuilder;

  RestartWidget({
    Key key,
    this.loadConfigBuilder,
  }) : super(key: key);

  static restartApp(BuildContext context, {bool loadConf = false}) {
    final _RestartWidgetState state =
      context.ancestorStateOfType(const TypeMatcher<_RestartWidgetState>());
    
    state.restartApp(loadConf);
  }

  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = new UniqueKey();
  bool loadConf = true;

  void restartApp(bool loadConfig) {
    this.loadConf = loadConfig;
    this.setState(() {
      key = new UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: key,
      child: widget.loadConfigBuilder((this.loadConf == null || this.loadConf) ? true : false),
    );
  }
}