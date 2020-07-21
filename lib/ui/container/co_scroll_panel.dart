import 'package:flutter/material.dart';
import 'i_container.dart';
import 'co_container.dart';

class CoScrollPanel extends CoContainer implements IContainer {
  ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;
  BoxConstraints constr;

  @override
  get preferredSize {
    if (constr != null) return constr.biggest;
    return super.preferredSize;
  }

  CoScrollPanel(GlobalKey componentId, BuildContext context)
      : super(componentId, context) {
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

    if (child != null) {
      return new LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        this.constr = constraints;
        return SingleChildScrollView(
            key: this.componentId,
            child: Container(color: this.background, child: child));
      });
    } else {
      return new Container();
    }
  }
}
