import '../../../custom/app_manager.dart';
import '../../service/api/shared/api_object_property.dart';

class UploadActionResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// File id to save the file back to the server
  String fileId;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  UploadActionResponse({
    required this.fileId,
    required super.originalRequest,
    required super.name,
  });

  UploadActionResponse.fromJson({required super.json, required super.originalRequest})
      : fileId = json[ApiObjectProperty.fileId],
        super.fromJson();
}
