import 'package:flutter/cupertino.dart';

class FlTabView extends StatefulWidget {
  final Widget child;
  const FlTabView({Key? key, required this.child}) : super(key: key);

  @override
  FlTabViewState createState() => FlTabViewState();
}

class FlTabViewState extends State<FlTabView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return widget.child;
  }
}
