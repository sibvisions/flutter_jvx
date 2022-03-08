import 'package:flutter/material.dart';

class FlGroupPanelWidget extends StatelessWidget {
  const FlGroupPanelWidget({Key? key, required this.children, this.width, this.height}) : super(key: key);

  final List<Widget> children;
  final double? width;
  final double? height;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IgnorePointer(
          ignoring: true,
          child: SizedBox(
            width: (width ?? 0),
            height: (height ?? 0),
          ),
        ),
        ...children,
      ],
    );
  }
}
