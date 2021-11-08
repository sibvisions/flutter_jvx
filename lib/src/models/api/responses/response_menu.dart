import 'package:flutter_jvx/src/models/api/responses.dart';

class ResponseMenu extends ApiResponse {
  final String componentId;
  final List<ResponseMenuEntry> responseMenuItems;


  ResponseMenu.fromJson(Map<String, dynamic> json) :
    componentId = json[_ResponseMenuParameters.componentId],
    responseMenuItems = (json[_ResponseMenuParameters.entries] as List<dynamic>).map((e) => ResponseMenuEntry.fromJson(e)).toList(),
    super.fromJson(json);
}

class ResponseMenuEntry {
  final String group;
  final String componentId;
  final String text;
  final String? image;

  ResponseMenuEntry({
    required this.componentId,
    required this.text,
    required this.group,
    this.image,
  });

  ResponseMenuEntry.fromJson(Map<String, dynamic> json) :
    componentId = json[_ResponseMenuParameters.componentId],
    text = json[_ResponseMenuParameters.text],
    image = json[_ResponseMenuParameters.image],
    group = json[_ResponseMenuParameters.group];
}

abstract class _ResponseMenuParameters{
  static const componentId = "componentId";
  static const entries = "entries";
  static const text = "text";
  static const group = "group";
  static const image = "image";
}