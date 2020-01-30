import 'package:flutter/material.dart';
import 'i_container.dart';
import 'jvx_container.dart';

class JVxPanel extends JVxContainer implements IContainer {
  JVxPanel(Key componentId, BuildContext context) : super(componentId, context);

  /*@override
  get preferredSize {
    return Size(300,500);
  }

  @override
  get minimumSize {
    return Size(50,500);
  }*/

  Widget getWidget() {
    Widget child;
    if (this.layout != null) {
      child = this.layout.getWidget();
    } else if (this.components.isNotEmpty) {
      child = this.components[0].getWidget();
    }

    if (child!= null) {
      return SingleChildScrollView( 
        child: Container(
            color: this.background, 
            child: SingleChildScrollView(
          scrollDirection: Axis.horizontal, 
          child: child)
        ));
    } else {
      return new Container();
    }
  }
}