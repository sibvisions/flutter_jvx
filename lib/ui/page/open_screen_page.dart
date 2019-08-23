import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/ui/jvx_screen.dart';

class OpenScreenPage extends StatelessWidget {
  final List<dynamic> changedComponents;
  final Key componentId;
  const OpenScreenPage({Key key, this.changedComponents, this.componentId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: JVxScreen(this.componentId, this.changedComponents).getWidget(),
    );
  }
}