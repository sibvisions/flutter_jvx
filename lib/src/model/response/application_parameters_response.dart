import '../../service/api/shared/api_object_property.dart';
import 'api_response.dart';

class ApplicationParametersResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final String? authenticated;

  /// Which screen to open, is a screen name
  final String? openScreen;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApplicationParametersResponse.fromJson(super.json)
      : authenticated = json[ApiObjectProperty.authenticated],
        openScreen = json[ApiObjectProperty.openScreen],
        super.fromJson();
}
