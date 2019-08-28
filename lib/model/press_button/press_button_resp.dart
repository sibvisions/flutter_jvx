import 'package:jvx_mobile_v3/model/changed_component.dart';

class PressButtonResponse {
  List<ChangedComponent> updatedComponents;
  String name;

  PressButtonResponse({this.updatedComponents, this.name});

  PressButtonResponse.fromJson(Map<String, dynamic> json)
    : updatedComponents = json[0]['changedComponents'],
      name = json[1]['name'];
}