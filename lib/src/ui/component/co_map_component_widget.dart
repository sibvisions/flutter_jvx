import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'component_widget.dart';
import 'model/map_component_model.dart';

class CoMapComponentWidget extends ComponentWidget {
  CoMapComponentWidget({required MapComponentModel componentModel})
      : super(componentModel: componentModel);

  @override
  State<StatefulWidget> createState() => CoMapComponentWidgetState();
}

class CoMapComponentWidgetState
    extends ComponentWidgetState<CoMapComponentWidget> {
  late MapController _controller;

  @override
  void initState() {
    _controller = MapController();

    WidgetsBinding.instance!.addPostFrameCallback((_) {});

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text('Map Component ist still in development!'),
      ),
    );
  }
}
