import 'package:flutter/material.dart';

class FlSplitPanelWidget extends StatelessWidget {
  const FlSplitPanelWidget({Key? key, required this.children}) : super(key: key);

  final List<Widget> children;


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: children,
    );
  }
}
