import 'package:jvx_mobile_v3/model/changed_component.dart';

class PressButtonResponse {
  List<ChangedComponent> updatedComponents;
  String name;

  PressButtonResponse({this.updatedComponents, this.name});

  PressButtonResponse.fromJson(List<dynamic> json) {
    updatedComponents = List();
    name = json[1]['name'];
    List<dynamic> chComp = json[0]['changedComponents'];

    chComp.forEach((val) {
      updatedComponents.add(ChangedComponent.fromJson(val));
    });
  }   
}