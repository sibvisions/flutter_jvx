import '../api_object_property.dart';
import 'api_response.dart';

class ApplicationMetaDataResponse extends ApiResponse {

  String? clientId;

  ApplicationMetaDataResponse.fromJson(Map<String, dynamic> json) :
    clientId = json[ApiObjectProperty.clientId],
    super.fromJson(json);
}