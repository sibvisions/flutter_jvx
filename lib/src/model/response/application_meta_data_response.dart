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

  /// Lang code of the app
  String langCode;

  /// Whether lost password feature is enabled.
  bool lostPasswordEnabled;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApplicationMetaDataResponse({
    required this.clientId,
    required this.version,
    required this.langCode,
    required this.lostPasswordEnabled,
    required super.originalRequest,
    required super.name,
  });

  ApplicationMetaDataResponse.fromJson({required super.json, required super.originalRequest})
      : clientId = json[ApiObjectProperty.clientId],
        version = json[ApiObjectProperty.version],
        langCode = json[ApiObjectProperty.langCode],
        lostPasswordEnabled = json[ApiObjectProperty.lostPasswordEnabled],
        super.fromJson();
}
