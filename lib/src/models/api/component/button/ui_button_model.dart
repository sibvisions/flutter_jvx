import 'package:flutter_jvx/src/models/api/component/ui_component_model.dart';
import 'package:flutter_jvx/src/models/api/jvx_property.dart';

class UIButtonModel extends UiComponentModel {
  final String text;

  UIButtonModel({
    required this.text,
    required String componentId,
    required String className,
    required String constraints,
    required String name,
    required String? parent
  }) : super(constraints: constraints,className: className,id: componentId,name: name, parent: parent);

  UIButtonModel.fromJson(Map<String, dynamic> json) :
    text = json[JVxProperty.text],
    super.fromJson(json);
}