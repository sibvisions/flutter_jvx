import 'package:flutter/cupertino.dart';

import '../../base_wrapper/base_comp_wrapper_widget.dart';

class FlTabView extends StatefulWidget {
  final BaseCompWrapperWidget child;
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
