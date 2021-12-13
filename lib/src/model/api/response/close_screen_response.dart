import 'package:flutter_client/src/model/api/api_object_property.dart';
import 'package:flutter_client/src/model/api/response/api_response.dart';

class CloseScreenResponse extends ApiResponse {

  /// Name of Screen to close (delete)
  final String componentId;

  CloseScreenResponse({
    required this.componentId,
    required String name
  }) : super(name: name);

  CloseScreenResponse.fromJson({required Map<String, dynamic> json}) :
    componentId = json[ApiObjectProperty.componentId],
    super.fromJson(json);

}