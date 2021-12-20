import 'package:flutter/material.dart';

class FlPanelWidget extends StatelessWidget {
   const FlPanelWidget({Key? key, required this.children, this.width, this.height}) : super(key: key);

  final List<Widget> children;
   final double? width;
   final double? height;
  @override
  Widget build(BuildContext context) {
    // return SizedBox(
    //   width: width,
    //   height: height,
    //   child: Stack(
    //     children: children
    //   ),
    // );
    //
    return Stack(
      children: children,
    );
  }
}