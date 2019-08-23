import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/ui/container/jvx_panel.dart';
import 'package:jvx_mobile_v3/ui/layout/jvx_border_layout.dart';
import 'component/i_component.dart';

class JVxScreen {
  Key componentId;
  List<IComponent> components = new List<IComponent>();

  JVxScreen(this.componentId, List<dynamic> changedComponentsJson) {

  }

  updateComponents(List<dynamic> changedComponentsJson) {

  }

  Widget getWidget() {
    // ToDO
    return Container(
      alignment: Alignment.center,
      child: Text('Test'),
    );
  }
}