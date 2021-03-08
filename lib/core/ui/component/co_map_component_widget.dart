import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'component_widget.dart';
import 'models/map_component_model.dart';

class CoMapComponentWidget extends ComponentWidget {
  final MapComponentModel componentModel;

  CoMapComponentWidget({this.componentModel});

  @override
  State<StatefulWidget> createState() => CoMapComponentWidgetState();
}

class CoMapComponentWidgetState
    extends ComponentWidgetState<CoMapComponentWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.componentModel.tileProvider == 'google') {
      return Container();
    } else {
      return FlutterMap(options: MapOptions(zoom: 13.0), layers: [
        new TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c']),
      ]);
    }
  }
}
