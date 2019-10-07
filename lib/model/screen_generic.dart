import 'package:jvx_mobile_v3/model/changed_component.dart';

class ScreenGeneric {
  String name;
  String componentId;
  List<ChangedComponent> changedComponents;

  ScreenGeneric({this.name, this.componentId, this.changedComponents});

  ScreenGeneric.fromChangedComponentsJson(Map<String, dynamic> json) {
    componentId = json['componentId'];

    changedComponents = getComponents(json['changedComponents']);
  }

  ScreenGeneric.fromUpdateComponentsJson(Map<String, dynamic> json) {
    componentId = json['componentId'];

    changedComponents = getComponents(json['updatedComponents']);
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