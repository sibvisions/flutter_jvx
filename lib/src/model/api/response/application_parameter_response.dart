import '../api_object_property.dart';
import 'api_response.dart';

class ApplicationParametersResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  String? authenticated;

  /// Which screen to open, is a screen name
  String? openScreen;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApplicationParametersResponse.fromJson({required Map<String, dynamic> pJson, required Object originalRequest})
      : authenticated = pJson[ApiObjectProperty.authenticated],
        openScreen = pJson[ApiObjectProperty.openScreen],
        super.fromJson(pJson: pJson, originalRequest: originalRequest);
}
