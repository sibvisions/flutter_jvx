import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/ui_refactor_2/component/component_model.dart';
import 'package:jvx_flutterclient/ui_refactor_2/container/co_container_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/container/container_component_model.dart';

class CoPanelWidget extends CoContainerWidget {
  CoPanelWidget({Key key, @required ComponentModel componentModel})
      : super(key: key, componentModel: componentModel);

  State<StatefulWidget> createState() => CoPanelWidgetState();
}

class CoPanelWidgetState extends CoContainerWidgetState {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.componentModel,
      builder: (context, value, child) {
        Widget child;
        if ((widget.componentModel as ContainerComponentModel).layout != null) {
          child = (widget.componentModel as ContainerComponentModel)
              .layout
              .getWidget();
        } else if ((widget.componentModel as ContainerComponentModel)
            .components
            .isNotEmpty) {
          child =
              (widget.componentModel as ContainerComponentModel).components[0];
        }

        if (child != null) {
          return Container(
              key: componentId, color: this.background, child: child);
          // return Container(
          //   color: this.background,
          //   child: child,
          // );
/*         return Container(
            key: componentId,
            color: this.background, 
            child: SingleChildScrollView(
          child: child
        ));   */
        } else {
          return new Container();
        }
      },
    );
  }
}
