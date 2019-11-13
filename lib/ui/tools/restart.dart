import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

class RestartWidget extends StatefulWidget {
  final Widget child;

  RestartWidget({this.child});

  static restartApp(BuildContext context) {
    globals.loadConf = false;

    final _RestartWidgetState state =
      context.ancestorStateOfType(const TypeMatcher<_RestartWidgetState>());
    
    state.restartApp();
  }

  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = new UniqueKey();

  void restartApp() {
    this.setState(() {
      key = new UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: key,
      child: widget.child,
    );
  }
}