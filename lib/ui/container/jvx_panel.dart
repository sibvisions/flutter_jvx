import 'package:flutter/material.dart';
import 'i_container.dart';
import 'jvx_container.dart';
import '../component/i_component.dart';

class JVxPanel extends JVxContainer implements IContainer {
  JVxPanel(Key componentId) : super(componentId);

  @override
  void add(IComponent pComponent) {
    // TODO: implement add
  }

  @override
  void addWithConstraints(IComponent pComponent, Object pConstraints) {
    // TODO: implement addWithConstraints
  }

  @override
  void remove(IComponent pComponent) {
    // TODO: implement remove
  }

  Widget getWidget() {
      return  new Container(key: componentId, child: this.layout.getWidget());
  }
}