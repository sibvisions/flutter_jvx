import '../../service/api/shared/api_object_property.dart';
import 'api_response.dart';

class UploadActionResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// File id to save the file back to the server
  final String fileId;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  UploadActionResponse({
    required this.fileId,
    required super.name,
  });

  UploadActionResponse.fromJson(super.json)
      : fileId = json[ApiObjectProperty.fileId],
        super.fromJson();
}
