import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/model/jvx_component.dart';

class OpenScreenResponse {
  List<JvxComponent> changedComponents;
  String name;
  String componentId;

  OpenScreenResponse({@required this.changedComponents, @required this.componentId, @required this.name});

  OpenScreenResponse.fromJson(List json) {
    changedComponents = List();
    name = json[0]['name'];
    componentId = json[0]['componentId'];

    List<dynamic> chComp = json[0]['changedComponents'];

    chComp.forEach((val) {
      changedComponents.add(JvxComponent.fromJson(val));
    });
  }
}