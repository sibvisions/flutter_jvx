import '../../../custom/app_manager.dart';
import '../../service/api/shared/api_object_property.dart';

class DownloadActionResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// File id
  String fileId;

  /// The file name
  String fileName;

  /// The url of where to download the file from.
  String url;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  DownloadActionResponse({
    required this.fileId,
    required this.fileName,
    required this.url,
    required super.originalRequest,
    required super.name,
  });

  DownloadActionResponse.fromJson({required super.json, required super.originalRequest})
      : fileId = json[ApiObjectProperty.fileId],
        url = json[ApiObjectProperty.url],
        fileName = json[ApiObjectProperty.fileName],
        super.fromJson();
}
