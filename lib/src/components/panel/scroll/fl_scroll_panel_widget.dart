import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../../model/component/panel/fl_panel_model.dart';
import '../fl_panel_widget.dart';

class FlScrollPanelWidget extends FlPanelWidget<FlPanelModel> {
  const FlScrollPanelWidget({
    super.key,
    required super.model,
    required super.children,
    required this.isScrollable,
    required this.width,
    required this.height,
    required this.viewWidth,
    required this.viewHeight,
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

      log("Viewheight: $viewHeight");
      log("height: $height");

      log("Viewwidth: $viewWidth");
      log("width: $width");

      if (kIsWeb) {
        return SingleChildScrollView(
          child: SizedBox(
            height: height,
            width: viewWidth,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                height: viewHeight,
                width: width,
                child: child,
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
