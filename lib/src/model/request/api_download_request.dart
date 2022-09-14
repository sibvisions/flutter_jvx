import '../../service/api/shared/api_object_property.dart';
import 'i_api_download_request.dart';
import 'i_session_request.dart';

class ApiDownloadRequest extends ISessionRequest implements IApiDownloadRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // The old way of downloading via the provided URL needs to be
  // a GET-request. But this way does not initialize the UI on the server side.
  // @override
  // Method get httpMethod => Method.GET;

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

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        ApiObjectProperty.name: "file",
        ApiObjectProperty.fileId: fileId,
        //ApiObjectProperty.fileName: fileName,
        //ApiObjectProperty.url: url,
      };
}
