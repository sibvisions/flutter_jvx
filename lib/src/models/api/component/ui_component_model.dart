class UiComponentModel {
  String id;
  String name;
  String className;
  String? constraints;
  String? parent;

  UiComponentModel({
    required this.id,
    required this.name,
    required this.className,
    required this.constraints,
    required this.parent
  });

  UiComponentModel.fromJson(Map<String, dynamic> json) :
    id = json[_PUiComponentModel.id],
    name = json[_PUiComponentModel.name],
    constraints = json[_PUiComponentModel.constraints],
    className = json[_PUiComponentModel.className],
    parent = json[_PUiComponentModel.parent];
}


abstract class _PUiComponentModel {
  static const String id = "id";
  static const String name = "name";
  static const String className = "className";
  static const String constraints = "constraints";
  static const String parent = "parent";
}