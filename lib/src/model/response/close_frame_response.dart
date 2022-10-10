import '../../service/api/shared/api_object_property.dart';
import 'api_response.dart';

class CloseFrameResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final String componentId;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  CloseFrameResponse({
    required this.componentId,
    required super.name,
    required super.originalRequest,
  });

  CloseFrameResponse.fromJson({required super.json, required super.originalRequest})
      : componentId = json[ApiObjectProperty.componentId],
        super.fromJson();
}
