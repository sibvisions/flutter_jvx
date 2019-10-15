import 'package:jvx_mobile_v3/model/api/response/response_object.dart';
import 'package:jvx_mobile_v3/model/changed_component.dart';

class ScreenGeneric extends ResponseObject {
  List<ChangedComponent> changedComponents;

  ScreenGeneric({this.changedComponents});

  ScreenGeneric.fromChangedComponentsJson(Map<String, dynamic> json) {
    changedComponents = getComponents(json['changedComponents']);
    super.name = json['name'];
    super.componentId = json['componentId'];
  }

  ScreenGeneric.fromUpdateComponentsJson(Map<String, dynamic> json) {
    componentId = json['componentId'];

    changedComponents = getComponents(json['updatedComponents']);
    super.name = json['name'];
    super.componentId = json['componentId'];
  }

  static getComponents(List json) {
    List<ChangedComponent> comps = <ChangedComponent>[];

    if (json != null) {
      json.forEach((val) {
        comps.add(ChangedComponent.fromJson(val));
      });
    }

    return comps;
  }
}