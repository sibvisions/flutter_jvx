import 'dart:developer';

import 'package:flutter/material.dart';

class FlScrollPanelWidget extends StatelessWidget {
  const FlScrollPanelWidget({Key? key, required this.children, this.width, this.height}) : super(key: key);

  final List<Widget> children;
  final double? width;
  final double? height;
  @override
  Widget build(BuildContext context) {
    log("Scroll panel has size: $width x $height");

    return SingleChildScrollView(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            width: width,
            height: (height ?? 0),
          ),
          ...children
        ],
      ),
    );
  }
}
