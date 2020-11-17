import '../response_object.dart';
import '../component/changed_component.dart';

class ScreenGeneric extends ResponseObject {
  List<ChangedComponent> changedComponents;
  bool update;

  get screenTitle {
    if (this.changedComponents != null && this.changedComponents.length > 0) {
      return this.changedComponents[0].screenTitle;
    }
  }

  ScreenGeneric({this.changedComponents});

  ScreenGeneric.fromChangedComponentsJson(Map<String, dynamic> json) {
    changedComponents = getComponents(json['changedComponents']);
    this.update = json['update'];

    super.name = json['name'];
    super.componentId = json['componentId'];
  }

  ScreenGeneric.fromUpdateComponentsJson(Map<String, dynamic> json) {
    componentId = json['componentId'];
    this.update = json['update'];

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
