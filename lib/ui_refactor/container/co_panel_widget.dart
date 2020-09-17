import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/ui_refactor/component/component_state.dart';

import 'container_widget.dart';

class CoPanelWidget extends StatefulWidget {
  @override
  _CoPanelWidgetState createState() => _CoPanelWidgetState();
}

class _CoPanelWidgetState extends State<CoPanelWidget> with ComponentState {
  @override
  Widget build(BuildContext context) {
    Widget child;
    if (CoContainerWidget.of(context).layout != null) {
      child = CoContainerWidget.of(context).layout.getWidget();
    } else if (CoContainerWidget.of(context).components.isNotEmpty) {
      child = CoContainerWidget.of(context).components[0];
    }

    if (child != null) {
      return Container(key: componentId, color: this.background, child: child);
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
  }
}
