import 'package:flutter_client/src/model/api/api_object_property.dart';
import 'package:flutter_client/src/model/api/response/api_response.dart';

class ScreenGenericResponse extends ApiResponse {

  final String componentId;
  final List<dynamic> changedComponents;

  ScreenGenericResponse({
    required this.componentId,
    required this.changedComponents,
    required String name,
  }) : super(name: name);


  ScreenGenericResponse.fromJson(Map<String, dynamic> json) :
    componentId = json[ApiObjectProperty.componentId],
    changedComponents = json[ApiObjectProperty.changedComponents],
    super.fromJson(json);
}