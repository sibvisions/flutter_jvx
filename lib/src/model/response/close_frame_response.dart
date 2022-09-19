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
    required String name,
    required Object originalRequest,
  }) : super(name: name, originalRequest: originalRequest);

  CloseFrameResponse.fromJson({required Map<String, dynamic> pJson, required Object originalRequest})
      : componentId = pJson[ApiObjectProperty.componentId],
        super.fromJson(pJson: pJson, originalRequest: originalRequest);
}
