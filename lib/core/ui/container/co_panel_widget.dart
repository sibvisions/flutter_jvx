import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/core/ui/container/co_scroll_panel_layout.dart';

import '../component/component_widget.dart';
import '../component/models/component_model.dart';
import 'co_container_widget.dart';
import 'container_component_model.dart';

class CoPanelWidget extends CoContainerWidget {
  CoPanelWidget({@required ComponentModel componentModel})
      : super(componentModel: componentModel);

  State<StatefulWidget> createState() => CoPanelWidgetState();
}

class CoPanelWidgetState extends CoContainerWidgetState {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  List<Widget> _getNullLayout(List<ComponentWidget> components) {
    List<Widget> children = <Widget>[];

    components.forEach((element) {
      if (element.componentModel.isVisible) {
        children.add(element);
      }
    });

    return children;
  }

  @override
  Widget build(BuildContext context) {
    ContainerComponentModel componentModel = widget.componentModel;

    Widget child;
    if (componentModel.layout != null) {
      // if (this.layout.setState != null) {
      //   this.layout.setState(() => child = this.layout as Widget);
      // } else {
      child = componentModel.layout as Widget;
      if (componentModel.layout.setState != null) {
        componentModel.layout.setState(() {});
      }
      // }
    } else if (componentModel.components.isNotEmpty) {
      child = Column(children: _getNullLayout(componentModel.components));
    }

    if (child != null) {
      // return LayoutBuilder(
      //     builder: (BuildContext context, BoxConstraints constraints) {
      //   return CoScrollPanelLayout(
      //       preferredConstraints:
      //           CoScrollPanelConstraints(constraints, componentModel),
      //       children: [
      //         CoScrollPanelLayoutId(
      //             constraints:
      //                 CoScrollPanelConstraints(constraints, componentModel),
      //             child: Container(
      //                 color: widget.componentModel.background, child: child))
      //       ]);
      // });
      return Container(
        color: widget.componentModel.background,
        child: child,
      );
/*         return Container(
            key: componentId,
            color: this.background, 
            child: SingleChildScrollView(
          child: child
        ));   */
    } else {
      return new Container();
    }
  }
}
