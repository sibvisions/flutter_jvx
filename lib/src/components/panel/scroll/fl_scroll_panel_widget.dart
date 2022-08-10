import 'package:flutter/widgets.dart';

class FlScrollPanelWidget extends StatelessWidget {
  const FlScrollPanelWidget({Key? key, required this.children, this.width, this.height, required this.isScrollable})
      : super(key: key);

  final bool isScrollable;
  final List<Widget> children;
  final double? width;
  final double? height;
  @override
  Widget build(BuildContext context) {
    if (isScrollable) {
      return InteractiveViewer(
        constrained: false,
        child: Stack(
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
        ),
      );
    } else {
      return Stack(
        children: children,
      );
    }
  }
}
