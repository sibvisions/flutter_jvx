import 'package:flutter/widgets.dart';

class FlPanelWidget extends StatelessWidget {
  const FlPanelWidget({Key? key, required this.children}) : super(key: key);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: children,
    );
  }
}
