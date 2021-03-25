import 'package:flutter/material.dart';

class RestartWidget extends StatefulWidget {
  final WidgetBuilder builder;

  const RestartWidget({Key? key, required this.builder}) : super(key: key);

  @override
  _RestartWidgetState createState() => _RestartWidgetState();

  static void restart(BuildContext context) {
    final _RestartWidgetState? state =
        context.findAncestorStateOfType<_RestartWidgetState>();

    if (state != null) {
      state.restart();
    }
  }
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = new UniqueKey();

  void restart() {
    setState(() {
      key = new UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(key: key, child: widget.builder(context));
  }
}
