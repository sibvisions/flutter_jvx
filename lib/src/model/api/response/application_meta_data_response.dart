import '../api_object_property.dart';
import 'api_response.dart';

class ApplicationMetaDataResponse extends ApiResponse {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// SessionId
  String clientId;

  /// Version of the remote app
  String version;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApplicationMetaDataResponse.fromJson(Map<String, dynamic> json) :
    clientId = json[ApiObjectProperty.clientId],
    version = json[ApiObjectProperty.version],
    super.fromJson(json);
}