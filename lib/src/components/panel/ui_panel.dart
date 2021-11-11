import 'package:flutter/material.dart';


class UIPanel extends StatelessWidget {
  const UIPanel({
    this.children = const [],
    Key? key
  }) : super(key: key);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: children,
    );
  }
}

