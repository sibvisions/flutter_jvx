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
    this.width,
    this.height,
  });

  final bool isScrollable;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    if (isScrollable) {
      return InteractiveViewer(
        constrained: false,
        scaleEnabled: !kIsWeb,
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
