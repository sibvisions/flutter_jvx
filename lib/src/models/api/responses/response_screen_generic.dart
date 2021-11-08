import 'package:flutter_jvx/src/models/api/responses.dart';

class ResponseScreenGeneric extends ApiResponse {

  final String componentId;
  final List<dynamic> changedComponents;
  final bool update;
  final bool home;



  ResponseScreenGeneric.fromJson(Map<String, dynamic> json) :
    componentId = json[_PResponseScreenGeneric.componentId],
    changedComponents = json[_PResponseScreenGeneric.changedComponents],
    update = json[_PResponseScreenGeneric.update],
    home = json[_PResponseScreenGeneric.home],
    super.fromJson(json);
}

abstract class _PResponseScreenGeneric{
  static const String componentId = "componentId";
  static const String changedComponents = "changedComponents";
  static const String update = "update";
  static const String home = "home";
}