import '../../../custom/app_manager.dart';
import 'i_api_download_request.dart';

class ApiDownloadRequest extends IApiDownloadRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  ConnectionType get conType => ConnectionType.GET;

  /// File id
  String fileId;

  /// The file name
  String fileName;

  /// The url
  String url;

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

  // @override
  // Map<String, dynamic> toJson() => {
  //       ...super.toJson(),
  // ApiObjectProperty.fileId: fileId,
  // ApiObjectProperty.fileName: fileName,
  // ApiObjectProperty.url: url,
  // };
}
