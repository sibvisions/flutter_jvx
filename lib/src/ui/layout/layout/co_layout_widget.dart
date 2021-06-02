import 'package:flutter/material.dart';
import 'package:flutterclient/src/ui/layout/layout/layout_model.dart';

class CoLayoutWidget extends StatefulWidget {
  final LayoutModel layoutModel;

  const CoLayoutWidget({Key? key, required this.layoutModel}) : super(key: key);

  @override
  CoLayoutWidgetState createState() => CoLayoutWidgetState();
}

class CoLayoutWidgetState<T extends StatefulWidget> extends State<T> {
  late GlobalKey layoutKey;

  void registerListener(LayoutModel layoutModel) {
    layoutModel.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    super.initState();

    layoutKey = GlobalKey(
        debugLabel: (widget as CoLayoutWidget)
            .layoutModel
            .container
            ?.componentModel
            .componentId);

    registerListener((widget as CoLayoutWidget).layoutModel);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
