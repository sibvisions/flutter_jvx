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

  /// Whether lost password feature is enabled.
  bool lostPasswordEnabled;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApplicationMetaDataResponse({
    required this.clientId,
    required this.version,
    required this.lostPasswordEnabled,
    required super.originalRequest,
    required super.name,
  });

  ApplicationMetaDataResponse.fromJson({required Map<String, dynamic> pJson, required Object originalRequest})
      : clientId = pJson[ApiObjectProperty.clientId],
        version = pJson[ApiObjectProperty.version],
        lostPasswordEnabled = pJson[ApiObjectProperty.lostPasswordEnabled],
        super.fromJson(originalRequest: originalRequest, pJson: pJson);
}
