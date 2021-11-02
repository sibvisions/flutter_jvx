import 'package:flutter_jvx/src/models/api/responses.dart';

class ResponseMenu extends ApiResponse {
  final String componentId;
  final List<ResponseMenuItem> responseMenuItems;


  ResponseMenu.fromJson(Map<String, dynamic> json) :
    componentId = json[_ResponseMenuParameters.componentId],
    responseMenuItems = (json[_ResponseMenuParameters.items] as List<dynamic>).map((e) => ResponseMenuItem.fromJson(e)).toList(),
    super.fromJson(json);
}

class ResponseMenuItem {
  final String group;
  final String? image;
  final ResponseMenuItemAction responseMenuItemAction;

  ResponseMenuItem({
    required this.group,
    this.image,
    required this.responseMenuItemAction
  });

  ResponseMenuItem.fromJson(Map<String, dynamic> json) :
    responseMenuItemAction = ResponseMenuItemAction.fromJson(json[_ResponseMenuParameters.action]),
    image = json[_ResponseMenuParameters.image],
    group = json[_ResponseMenuParameters.group];
}

class ResponseMenuItemAction {
  final String componentId;
  final String label;


  ResponseMenuItemAction({
    required this.componentId,
    required this.label
  });

  ResponseMenuItemAction.fromJson(Map<String, dynamic> json) :
    componentId = json[_ResponseMenuParameters.componentId],
    label = json[_ResponseMenuParameters.label];
}


abstract class _ResponseMenuParameters{
  static const componentId = "componentId";
  static const items = "items";
  static const label = "label";
  static const group = "group";
  static const image = "image";
  static const action = "action";
}