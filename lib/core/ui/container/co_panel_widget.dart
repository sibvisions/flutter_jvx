import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../component/models/component_model.dart';
import '../component/component_widget.dart';
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
    Widget child;
    if (this.layout != null) {
      // if (this.layout.setState != null) {
      //   this.layout.setState(() => child = this.layout as Widget);
      // } else {
      child = this.layout as Widget;
      if (this.layout.setState != null) {
        this.layout.setState(() {});
      }
      // }
    } else if (this.components.isNotEmpty) {
      child = Column(children: _getNullLayout(this.components));
    }

    if (child != null) {
      return Container(color: widget.componentModel.background, child: child);
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
