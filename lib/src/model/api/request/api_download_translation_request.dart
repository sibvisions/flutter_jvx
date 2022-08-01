import '../api_object_property.dart';
import 'i_api_download_request.dart';

class ApiDownloadTranslationRequest extends IApiDownloadRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Session Id
  final String clientId;

  /// Name of request, will always be - "translation"
  final String name;

  /// Mode of request, will always be - "json"
  final String contentMode;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiDownloadTranslationRequest({
    required this.clientId,
    this.name = "translation",
    this.contentMode = "json",
  });

  @override
  Map<String, dynamic> toJson() => {
        ApiObjectProperty.clientId: clientId,
        ApiObjectProperty.name: name,
        ApiObjectProperty.contentMode: contentMode,
      };
}
