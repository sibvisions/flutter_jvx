import '../api_object_property.dart';
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
    required String name,
    required Object originalRequest,
  }) : super(name: name, originalRequest: originalRequest);

  CloseScreenResponse.fromJson({required Map<String, dynamic> pJson, required Object originalRequest})
      : screenName = pJson[ApiObjectProperty.componentId],
        super.fromJson(pJson: pJson, originalRequest: originalRequest);
}
