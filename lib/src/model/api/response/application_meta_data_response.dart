import 'package:flutter_client/src/model/api/api_object_property.dart';
import 'package:flutter_client/src/model/api/response/api_response.dart';

class ApplicationMetaDataResponse extends ApiResponse {

  String? clientId;

  ApplicationMetaDataResponse.fromJson(Map<String, dynamic> json) :
    clientId = json[ApiObjectProperty.clientId],
    super.fromJson(json);
}