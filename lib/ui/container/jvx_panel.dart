import 'package:flutter/material.dart';
import 'i_container.dart';
import 'jvx_container.dart';

class JVxPanel extends JVxContainer implements IContainer {
  JVxPanel(Key componentId) : super(componentId);

  Widget getWidget() {
    if (this.layout!= null) {
      return  new Container(key: componentId, child: this.layout.getWidget());
    } else {
      // TODO no layout defined
    }
  }
}