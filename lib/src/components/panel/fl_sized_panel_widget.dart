import 'dart:math';

import 'package:flutter/widgets.dart';

class FlSizedPanelWidget extends StatelessWidget {
  const FlSizedPanelWidget({Key? key, required this.children, this.width, this.height}) : super(key: key);

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
            width: max((width ?? 0), 0),
            height: max((height ?? 0), 0),
          ),
        ),
        ...children,
      ],
    );
  }
}
