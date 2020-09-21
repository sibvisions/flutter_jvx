import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/ui_refactor_2/component/component_model.dart';
import 'package:jvx_flutterclient/ui_refactor_2/container/co_container_widget.dart';

class CoPanelWidget extends CoContainerWidget {
  CoPanelWidget({Key key, @required ComponentModel componentModel})
      : super(key: key, componentModel: componentModel);

  State<StatefulWidget> createState() => CoPanelWidgetState();
}

class CoPanelWidgetState extends CoContainerWidgetState {
  @override
  void initState() {
    super.initState();
    this.updateProperties(widget.componentModel.currentChangedComponent);
    widget.componentModel.componentState = this;
    widget.componentModel.addListener(() =>
        this.updateProperties(widget.componentModel.currentChangedComponent));
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (this.layout != null) {
      child = this.layout.getWidget();
    } else if (this.components.isNotEmpty) {
      child = this.components[0];
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
