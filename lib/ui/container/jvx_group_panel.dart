import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/model/changed_component.dart';
import 'package:jvx_mobile_v3/model/properties/component_properties.dart';
import 'package:jvx_mobile_v3/ui/container/i_container.dart';
import 'package:jvx_mobile_v3/ui/container/jvx_container.dart';


class JVxGroupPanel extends JVxContainer implements IContainer {
  String text = "";
  JVxGroupPanel(Key componentId, BuildContext context) : super(componentId, context);

  void updateProperties(ChangedComponent changedcomponent) {
    super.updateProperties(changedcomponent);
    text = changedcomponent.getProperty<String>(ComponentProperty.TEXT, text);
  }

  Widget getWidget() {
    Widget child;
    if (this.layout != null) {
      child = this.layout.getWidget();
    } else if (this.components.isNotEmpty) {
      child = this.components[0].getWidget();
    }

    if (child!= null) {
      return Container(
            padding: EdgeInsets.fromLTRB(5, 10, 5, 5),
            color: this.background, 
            child: Container(
              decoration: new BoxDecoration(
              color: Colors.grey[600],
                  borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(5.0),
                      topRight: const Radius.circular(5.0))),
              child: Container(
                margin: EdgeInsets.fromLTRB(1, 1, 1, 1),
                decoration: new BoxDecoration(
                color: Colors.white,
                    borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(5.0),
                        topRight: const Radius.circular(5.0))),
                child: child)
            )
        );
    } else {
      return new Container();
    }
  }
}