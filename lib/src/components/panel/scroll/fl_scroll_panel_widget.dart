import 'package:flutter/widgets.dart';

import '../../../../components.dart';

class FlScrollPanelWidget extends FlPanelWidget<FlPanelModel> {
  const FlScrollPanelWidget(
      {super.key, required super.children, this.width, this.height, required this.isScrollable, required super.model});

  final bool isScrollable;
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
              child: Container(
                color: model.background,
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
