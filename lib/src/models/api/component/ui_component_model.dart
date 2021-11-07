abstract class UiComponentModel {
  String componentId;
  String name;
  String className;
  String? constraints;
  String? parent;

  UiComponentModel({
    required this.componentId,
    required this.name,
    required this.className,
    required this.constraints,
    required this.parent
  });
}