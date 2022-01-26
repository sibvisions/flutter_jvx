import 'package:flutter/material.dart';

class FlScrollPanelWidget extends StatelessWidget {
  const FlScrollPanelWidget({Key? key, required this.children, this.width, this.height}) : super(key: key);

  final List<Widget> children;
  final double? width;
  final double? height;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: children,
    );
  }
}
