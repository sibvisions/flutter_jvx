import '../../service/api/shared/api_object_property.dart';
import 'api_response.dart';

class DownloadActionResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// File id
  final String fileId;

  /// The file name
  final String fileName;

  /// The url of where to download the file from.
  final String url;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  DownloadActionResponse({
    required this.fileId,
    required this.fileName,
    required this.url,
    required super.name,
  });

  DownloadActionResponse.fromJson(super.json)
      : fileId = json[ApiObjectProperty.fileId],
        url = json[ApiObjectProperty.url],
        fileName = json[ApiObjectProperty.fileName],
        super.fromJson();
}
