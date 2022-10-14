import '../../service/api/shared/api_object_property.dart';
import '../../service/api/shared/api_response_names.dart';

class ApiResponse<T extends Object> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Name of response - possible names are listed in [ApiResponseNames]
  final String name;

  /// Raw json from this response
  final Map<String, dynamic> json;

  /// Original Request that provoked this response
  final T originalRequest;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiResponse({
    required this.name,
    this.json = const {},
    required this.originalRequest,
  });

  ApiResponse.fromJson(this.json, this.originalRequest) : name = json[ApiObjectProperty.name];
}
