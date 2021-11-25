import '../api/api_object_property.dart';

abstract class FlComponentModel {
  final String id;
  final String name;
  final String className;
  final String? constraints;
  final String? parent;

  FlComponentModel.fromJson(Map<String, dynamic> json) :
    name = json[ApiObjectProperty.name],
    className = json[ApiObjectProperty.className],
    parent = json[ApiObjectProperty.parent],
    id = json[ApiObjectProperty.id],
    constraints = json[ApiObjectProperty.constraints];


  FlComponentModel.updatedProperties(FlComponentModel oldModel, dynamic json) :
    name = oldModel.name,
    id = oldModel.id,
    className = oldModel.className,
    parent = json[ApiObjectProperty.parent] ?? oldModel.parent,
    constraints = json[ApiObjectProperty.constraints] ?? oldModel.constraints;

  FlComponentModel updateComponent(FlComponentModel oldModel, dynamic json);

}