import '../../service/api/shared/api_object_property.dart';
import 'download_request.dart';

/// The old way of downloading via the provided URL needs to be
/// a GET-request. But this way does not initialize the UI on the server side.
class ApiDownloadRequest extends DownloadRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Name of the request, will always be "file"
  final String name = "file";

  /// File id
  final String fileId;

  /// The file name
  final String fileName;

  /// The url
  final String url;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiDownloadRequest({
    required this.url,
    required this.fileName,
    required this.fileId,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        ApiObjectProperty.name: name,
        ApiObjectProperty.fileId: fileId,
        //ApiObjectProperty.fileName: fileName,
        //ApiObjectProperty.url: url,
      };
}
