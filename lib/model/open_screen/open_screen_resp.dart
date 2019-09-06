import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/model/changed_component.dart';

class OpenScreenResponse {
  List<ChangedComponent> changedComponents;
  String name;
  String componentId;

  OpenScreenResponse({@required this.changedComponents, @required this.componentId, @required this.name});

  OpenScreenResponse.fromJson(List json) {
    if (json[0]['title'] == 'Error')
      return;
      
    changedComponents = [];
    name = json[0]['name'];
    componentId = json[0]['componentId'];

    List<dynamic> chComp = json[0]['changedComponents'];

    chComp.forEach((val) {
      changedComponents.add(ChangedComponent.fromJson(val));
    });
  }
  
}