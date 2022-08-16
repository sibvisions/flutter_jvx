import '../../service/api/shared/api_object_property.dart';
import '../../service/api/shared/api_response_names.dart';

class ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Name of response - possible names are listed in [ApiResponseNames]
  final String name;

  /// Raw json from this response
  final Map<String, dynamic>? json;

  /// Original Request that provoked this response
  final Object originalRequest;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiResponse({
    required this.name,
    this.json,
    required this.originalRequest,
  });

  ApiResponse.fromJson({
    required Map<String, dynamic> pJson,
    required this.originalRequest,
  })  : name = pJson[ApiObjectProperty.name],
        json = pJson;
}
