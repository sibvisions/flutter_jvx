import 'package:flutter/material.dart';
import 'i_container.dart';
import 'jvx_container.dart';

class JVxScrollPanel extends JVxContainer implements IContainer {
  ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;
  
  JVxScrollPanel(GlobalKey componentId, BuildContext context) : super(componentId, context) {
    _scrollController.addListener(_scrollListener);
  }

  _scrollListener() {
    this._scrollOffset = _scrollController.offset;
  }

  Widget getWidget() {
    Widget child;
    if (this.layout != null) {
      child = this.layout.getWidget();
    } else if (this.components.isNotEmpty) {
      child = this.components[0].getWidget();
    }

    if (child!= null) {
      return SingleChildScrollView(
          key: this.componentId,
          child: Container(
                color: this.background, 
                child: child
              )
        );
    } else {
      return new Container();
    }
  }
}