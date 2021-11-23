import 'package:flutter_client/src/model/api/api_object_property.dart';

class FlComponentModel {
  final String id;
  final String name;
  final String className;
  String? parent;

  FlComponentModel.fromJson(Map<String, dynamic> json) :
    name = json[ApiObjectProperty.name],
    className = json[ApiObjectProperty.className],
    parent = json[ApiObjectProperty.parent],
    id = json[ApiObjectProperty.id];
}