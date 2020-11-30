import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jvx_flutterclient/core/models/api/request.dart';
import 'package:jvx_flutterclient/core/services/remote/bloc/api_bloc.dart';
import 'package:jvx_flutterclient/core/ui/screen/component_screen_widget.dart';
import 'package:jvx_flutterclient/core/ui/widgets/util/app_state_provider.dart';

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
  ScrollController _scrollController;
  double scrollOffset = 0;
  BoxConstraints constr;

  @override
  get preferredSize {
    if (constr != null) return constr.biggest;
    return widget.componentModel.preferredSize;
  }

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

      // return SingleChildScrollView(
      //     key: this.componentId,
      //     child: Container(color: this.background, child: child));
      return Container(
          color: widget.componentModel.background,
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
