import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../model/component/panel/fl_panel_model.dart';
import '../fl_panel_widget.dart';

class FlScrollPanelWidget extends FlPanelWidget<FlPanelModel> {
  final ScrollController horizontalScrollController;

  final ScrollController verticalScrollController;

  const FlScrollPanelWidget({
    super.key,
    required super.model,
    required super.children,
    required this.isScrollable,
    required this.width,
    required this.height,
    required this.viewWidth,
    required this.viewHeight,
    required this.horizontalScrollController,
    required this.verticalScrollController,
  });

  final bool isScrollable;
  final double width;
  final double height;
  final double viewWidth;
  final double viewHeight;

  @override
  Widget build(BuildContext context) {
    if (isScrollable) {
      Widget child = Stack(
        children: [
          IgnorePointer(
            ignoring: true,
            child: Container(
              color: model.background,
              width: (width),
              height: (height),
            ),
          ),
          ...children,
        ],
      );

      if (kIsWeb) {
        return Scrollbar(
          thumbVisibility: true,
          controller: horizontalScrollController,
          child: Scrollbar(
            controller: verticalScrollController,
            notificationPredicate: (notification) => notification.depth == 1,
            child: SizedBox(
              width: viewWidth,
              height: viewHeight,
              child: SingleChildScrollView(
                controller: horizontalScrollController,
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  controller: verticalScrollController,
                  child: child,
                ),
              ),
            ),
          ),
        );
      } else {
        return InteractiveViewer(
          constrained: false,
          child: child,
        );
      }
    } else {
      return Stack(
        children: children,
      );
    }
  }
}
