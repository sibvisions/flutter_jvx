import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/jvx_flutterclient.dart';
import 'i_container.dart';
import 'co_container.dart';

class CoPanel extends CoContainer implements IContainer {
  CoPanel(GlobalKey componentId, BuildContext context)
      : super(componentId, context);

  factory CoPanel.withCompContext(ComponentContext componentContext) {
    return CoPanel(componentContext.globalKey, componentContext.context);
  }

  /*@override
  get preferredSize {
    return Size(300,500);
  }

  @override
  get minimumSize {
    return Size(50,500);
  }*/

  Widget getWidget() {
    Widget child;
    if (this.layout != null) {
      child = this.layout.getWidget();
    } else if (this.components.isNotEmpty) {
      child = this.components[0].getWidget();
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
