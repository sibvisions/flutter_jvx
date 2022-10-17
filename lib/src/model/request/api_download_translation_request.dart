import '../../service/api/shared/api_object_property.dart';
import 'download_request.dart';

class ApiDownloadTranslationRequest extends DownloadRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Name of request, will always be - "translation"
  final String name = "translation";

  /// Mode of request, will always be - "json"
  final String contentMode = "json";

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiDownloadTranslationRequest();

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        ApiObjectProperty.name: name,
        ApiObjectProperty.contentMode: contentMode,
      };
}
