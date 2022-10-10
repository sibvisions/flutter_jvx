import '../../service/api/shared/api_object_property.dart';
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

  ApplicationParametersResponse.fromJson({required super.json, required super.originalRequest})
      : authenticated = json[ApiObjectProperty.authenticated],
        openScreen = json[ApiObjectProperty.openScreen],
        super.fromJson();
}
