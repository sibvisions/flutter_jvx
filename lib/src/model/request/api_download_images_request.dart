import '../../service/api/shared/api_object_property.dart';
import 'download_request.dart';

/// Request to download all images the app needs
class ApiDownloadImagesRequest extends DownloadRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Name of the request, will always be "images"
  final String name = "images";

  /// Set to true to download all images of the library
  final bool libraryImages = true;

  /// Set to true to download all images of the app
  final bool applicationImages = true;

  /// Content mode of images, will always be null
  final String? contentMode = null;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiDownloadImagesRequest();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        ApiObjectProperty.name: name,
        ApiObjectProperty.libraryImages: libraryImages,
        ApiObjectProperty.applicationImages: applicationImages,
        ApiObjectProperty.contentMode: contentMode
      };
}
