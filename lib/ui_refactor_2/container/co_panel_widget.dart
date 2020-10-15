import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/model/changed_component.dart';
import '../component/component_model.dart';
import 'co_container_widget.dart';

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

  @override
  void didUpdateWidget(CoContainerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.componentModel.changedComponent != null) {
      layout = createLayout(widget, widget.componentModel.changedComponent);
    }
    this.update();

    widget.componentModel.addListener(() => setState(() => this.update()));
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (this.layout != null) {
      // if (this.layout.setState != null) {
      //   this.layout.setState(() => child = this.layout as Widget);
      // } else {
      child = this.layout as Widget;
      // }
    } else if (this.components.isNotEmpty) {
      child = this.components[0];
    }

    if (child != null) {
      return Container(color: this.background, child: child);
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
