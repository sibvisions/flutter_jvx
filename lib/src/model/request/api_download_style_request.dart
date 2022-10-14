import '../../service/api/shared/api_object_property.dart';
import 'i_api_download_request.dart';
import 'session_request.dart';

class ApiDownloadStyleRequest extends SessionRequest implements IApiDownloadRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Name of the request, will always be "applicationStyle"
  final String name = "applicationStyle";

  /// Set to true to download all images of the library
  final bool libraryImages = false;

  /// Set to true to download all images of the app
  final bool applicationImages = false;

  /// Content mode of styles will always be json
  final String contentMode = "json";

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiDownloadStyleRequest();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        ApiObjectProperty.name: name,
        ApiObjectProperty.libraryImages: libraryImages,
        ApiObjectProperty.applicationImages: applicationImages,
        ApiObjectProperty.contentMode: contentMode,
      };
}
