import '../../service/api/shared/api_object_property.dart';
import 'api_response.dart';

class CloseScreenResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Name of Screen to close
  final String screenName;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  CloseScreenResponse({
    required this.screenName,
    required super.name,
    required super.originalRequest,
  });

  CloseScreenResponse.fromJson({required super.json, required super.originalRequest})
      : screenName = json[ApiObjectProperty.componentId],
        super.fromJson();
}
