import 'package:flutter/material.dart';
import 'package:flutter_google_maps/flutter_google_maps.dart';

import 'component_widget.dart';
import 'models/map_component_model.dart';

class CoMapComponentWidget extends ComponentWidget {
  final MapComponentModel componentModel;

  CoMapComponentWidget({this.componentModel});

  @override
  State<StatefulWidget> createState() => CoMapComponentWidgetState();
}

class CoMapComponentWidgetState extends ComponentWidgetState {
  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      
    );
  }
}
