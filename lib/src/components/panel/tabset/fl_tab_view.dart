import 'package:flutter/cupertino.dart';

class FlTabView extends StatefulWidget {
  final Widget child;
  const FlTabView({Key? key, required this.child}) : super(key: key);

  @override
  FlTabViewState createState() => FlTabViewState();
}

class FlTabViewState extends State<FlTabView> with AutomaticKeepAliveClientMixin {
  bool _keepAlive = true;

  @override
  bool get wantKeepAlive => _keepAlive;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    BuildContext? childContext = (widget.child.key as GlobalKey).currentContext;
    if (childContext != null) {
      Widget? parentWidget = childContext.findAncestorWidgetOfExactType<FlTabView>();
      if (parentWidget != widget) {
        _keepAlive = false;
        updateKeepAlive();
      }
    }

    if (_keepAlive) {
      return widget.child;
    } else {
      return Container();
    }
  }
}
