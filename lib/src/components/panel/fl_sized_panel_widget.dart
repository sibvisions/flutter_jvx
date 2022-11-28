import 'dart:math';

import 'package:flutter/widgets.dart';

import 'fl_panel_widget.dart';

class FlSizedPanelWidget extends FlPanelWidget {
  const FlSizedPanelWidget({
    super.key,
    required super.model,
    required super.children,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IgnorePointer(
          ignoring: true,
          child: Container(
            color: model.background,
            width: max((width ?? 0), 0),
            height: max((height ?? 0), 0),
          ),
        ),
        ...children,
      ],
    );
  }
}
