import '../../service/api/shared/api_object_property.dart';
import 'i_api_download_request.dart';
import 'i_session_request.dart';

class ApiDownloadTranslationRequest extends ISessionRequest implements IApiDownloadRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Name of request, will always be - "translation"
  final String name;

  /// Mode of request, will always be - "json"
  final String contentMode;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiDownloadTranslationRequest({
    this.name = "translation",
    this.contentMode = "json",
  });

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        ApiObjectProperty.name: name,
        ApiObjectProperty.contentMode: contentMode,
      };
}
