import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class FlTabHeader extends StatelessWidget {
  final List<Widget> tabHeaderList;
  final Function(BuildContext) postFrameCallback;

  const FlTabHeader({Key? key, required this.tabHeaderList, required this.postFrameCallback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabHeaderList,
      ),
    );
  }
}
