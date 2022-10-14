import '../../service/api/shared/api_object_property.dart';
import '../../service/api/shared/api_response_names.dart';

class ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Name of response - possible names are listed in [ApiResponseNames]
  final String name;

  /// Raw json from this response
  final Map<String, dynamic> json;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiResponse({
    required this.name,
    this.json = const {},
  });

  ApiResponse.fromJson(this.json) : name = json[ApiObjectProperty.name];
}
