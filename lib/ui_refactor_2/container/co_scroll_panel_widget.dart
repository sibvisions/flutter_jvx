import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/ui_refactor_2/component/component_model.dart';

import 'co_container_widget.dart';
import 'co_scroll_panel_layout.dart';
import 'container_component_model.dart';

class CoScrollPanelWidget extends CoContainerWidget {
  CoScrollPanelWidget({@required ContainerComponentModel componentModel})
      : super(componentModel: componentModel);

  @override
  CoScrollPanelWidgetState createState() => CoScrollPanelWidgetState();
}

class CoScrollPanelWidgetState extends CoContainerWidgetState {
  ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;
  BoxConstraints constr;

  @override
  get preferredSize {
    if (constr != null) return constr.biggest;
    return super.preferredSize;
  }

  _scrollListener() {
    this._scrollOffset = _scrollController.offset;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (this.layout != null) {
      child = this.layout as Widget;
      if (this.layout.setState != null) {
        this.layout.setState(() {});
      }
    } else if (this.components.isNotEmpty) {
      child = Column(children: this.components);
    }

    Widget scrollWidget = new LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      this.constr = constraints;

      // return SingleChildScrollView(
      //     key: this.componentId,
      //     child: Container(color: this.background, child: child));
      return Container(
          color: this.background,
          child: SingleChildScrollView(
              controller: _scrollController,
              // key: this.componentId,
              child: CoScrollPanelLayout(
                preferredConstraints: CoScrollPanelConstraints(constraints),
                children: [
                  CoScrollPanelLayoutId(
                      // key: ValueKey(widget.key),
                      constraints: CoScrollPanelConstraints(constraints),
                      child: child)
                ],
              )));
    });

    if (child != null) {
      return scrollWidget;
    } else {
      return new Container();
    }
  }
}
