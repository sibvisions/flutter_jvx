import 'package:universal_io/io.dart';

import '../../service/api/shared/api_object_property.dart';
import '../../service/api/shared/api_response_names.dart';
import 'i_api_request.dart';

/// Request to change the password of the user
class ApiUploadRequest extends IApiRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Session id
  final String clientId;

  /// The id of the file for the server.
  String fileId;

  /// The file to send.
  File file;

  /// Name of request, will always be - "translation"
  final String name;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiUploadRequest({
    this.name = ApiResponseNames.upload,
    required this.clientId,
    required this.file,
    required this.fileId,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Map<String, dynamic> toJson() => {
        ApiObjectProperty.fileId: fileId,
        ApiObjectProperty.file: file,
        ApiObjectProperty.clientId: clientId,
        ApiObjectProperty.name: name,
      };
}
