import 'package:flutter/widgets.dart';

import '../../../components.dart';

class FlPanelWidget<T extends FlPanelModel> extends FlStatelessWidget<T> {
  const FlPanelWidget({super.key, required super.model, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: model.background,
        ),
        ...children
      ],
    );
  }
}
