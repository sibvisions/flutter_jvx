import 'package:flutter/material.dart';

import 'co_container_widget.dart';
import 'co_scroll_panel_layout.dart';
import 'models/container_component_model.dart';

class CoScrollPanelWidget extends CoContainerWidget {
  CoScrollPanelWidget({required ContainerComponentModel componentModel})
      : super(componentModel: componentModel);

  @override
  CoScrollPanelWidgetState createState() => CoScrollPanelWidgetState();
}

class CoScrollPanelWidgetState extends CoContainerWidgetState {
  late ScrollController _scrollController;
  double scrollOffset = 0;
  // BoxConstraints? constr;

  // get preferredSize {
  //   if (constr != null) return constr!.biggest;
  //   return widget.componentModel.preferredSize;
  // }

  _scrollListener() {
    this.scrollOffset = _scrollController.offset;
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() => _scrollListener());
  }

  @override
  Widget build(BuildContext context) {
    ContainerComponentModel componentModel =
        widget.componentModel as ContainerComponentModel;

    Widget? child;
    if (componentModel.layout != null) {
      child = componentModel.layout;
    } else if (componentModel.components.isNotEmpty) {
      child = Column(children: componentModel.components);
    }

    Widget scrollWidget = new LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      //this.constr = constraints;

      // return SingleChildScrollView(
      //     key: this.componentId,
      //     child: Container(color: this.background, child: child));
      return Container(
          color: widget.componentModel.background,
          child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _scrollController,
                  // key: this.componentId,
                  child: CoScrollPanelLayout(
                    preferredConstraints: CoScrollPanelConstraints(
                        constraints, componentModel, constraints.biggest),
                    container: widget.componentModel as ContainerComponentModel,
                    children: [
                      CoScrollPanelLayoutId(
                          // key: ValueKey(widget.key),
                          constraints: CoScrollPanelConstraints(
                              constraints, componentModel, constraints.biggest),
                          child: child ?? Container())
                    ],
                  ))));
    });

    if (child != null) {
      return scrollWidget;
    } else {
      return new Container();
    }
  }
}
