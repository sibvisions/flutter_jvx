import 'package:flutter_jvx/src/models/api/component/ui_component_model.dart';

class UiPanelModel extends UiComponentModel {

  String layout;
  String? layoutData;
  String? screenClassName;

  UiPanelModel({
    required this.layoutData,
    required this.layout,
    required String componentId,
    required String className,
    required String constraints,
    required String name,
    required String? parent
  }) : super(constraints: constraints,className: className,id: componentId,name: name, parent: parent);

}