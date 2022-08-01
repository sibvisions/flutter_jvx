import '../../service/api/shared/api_object_property.dart';
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

  ApplicationMetaDataResponse({
    required this.version,
    required this.clientId,
    required Object originalRequest,
    required String name,
  }) : super(originalRequest: originalRequest, name: name);

  ApplicationMetaDataResponse.fromJson({required Map<String, dynamic> pJson, required Object originalRequest})
      : clientId = pJson[ApiObjectProperty.clientId],
        version = pJson[ApiObjectProperty.version],
        super.fromJson(originalRequest: originalRequest, pJson: pJson);
}
