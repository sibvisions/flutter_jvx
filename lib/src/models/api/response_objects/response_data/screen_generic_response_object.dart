import '../../response_object.dart';
import 'component/changed_component.dart';

class ScreenGenericResponseObject extends ResponseObject {
  final List<ChangedComponent> changedComponents;
  final bool update;

  String? get screenTitle {
    if (changedComponents.isNotEmpty) {
      return changedComponents[0].screenTitle;
    }

    return null;
  }

  ScreenGenericResponseObject(
      {required String name,
      required this.changedComponents,
      required this.update,
      String? componentId})
      : super(name: name, componentId: componentId);

  ScreenGenericResponseObject.fromJson({required Map<String, dynamic> map})
      : update = map['update'],
        changedComponents = getComponents(
            list: map['changedComponents'] ?? map['updatedComponents']),
        super.fromJson(map: map);

  static List<ChangedComponent> getComponents({required List<dynamic> list}) {
    List<ChangedComponent> comps = [];

    list.forEach(
        (component) => comps.add(ChangedComponent.fromJson(component)));

    return comps;
  }
}
