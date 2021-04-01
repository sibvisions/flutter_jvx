import 'dart:developer';

import 'package:flutter/material.dart';

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
  ScrollController _scrollController1;
  ScrollController _scrollController2;
  double scrollOffset = 0;
  BoxConstraints constr;

  @override
  get preferredSize {
    if (constr != null) return constr.biggest;
    return widget.componentModel.preferredSize;
  }

  _scrollListener() {
    this.scrollOffset = _scrollController1.offset;
  }

  @override
  void initState() {
    super.initState();
    _scrollController1 = ScrollController();
    _scrollController1.addListener(() => _scrollListener());
    _scrollController2 = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    ContainerComponentModel componentModel = widget.componentModel;

    Widget child;
    if (componentModel.layout != null) {
      child = componentModel.layout as Widget;
      if (componentModel.layout.setState != null) {
        componentModel.layout.setState(() {});
      }
    } else if (componentModel.components.isNotEmpty) {
      child = Column(children: componentModel.components);
    }

    Widget scrollWidget = new LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      this.constr = constraints;

      final double maxWidth = constraints.maxWidth == double.infinity
          ? MediaQuery.of(context).size.width
          : constraints.maxWidth;
      final double maxHeight = constraints.maxHeight == double.infinity
          ? MediaQuery.of(context).size.height
          : constraints.maxHeight;

      BoxConstraints constraints1 = BoxConstraints(
          minWidth: constraints.minWidth,
          maxWidth: maxWidth,
          minHeight: constraints.minHeight,
          maxHeight: maxHeight);

      return Container(
          color: widget.componentModel.background,
          child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              controller: _scrollController1,
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _scrollController2,
                  child: LayoutBuilder(builder:
                      (BuildContext context, BoxConstraints constraints) {
                    log("ScrollPanelWidget parent constraints: $constraints");
                    return CoScrollPanelLayout(
                      preferredConstraints: CoScrollPanelConstraints(
                          constraints1, componentModel, constraints1.biggest),
                      children: [
                        CoScrollPanelLayoutId(
                            // key: ValueKey(widget.key),
                            constraints: CoScrollPanelConstraints(constraints,
                                componentModel, constraints1.biggest),
                            child: child)
                      ],
                    );
                  }))));
    });

    if (child != null) {
      return scrollWidget;
    } else {
      return new Container();
    }
  }
}
