import '../api_object_property.dart';
import 'api_response.dart';

class ApplicationParametersResponse extends ApiResponse {
  String? authenticated;
  String? openScreen;

  ApplicationParametersResponse.fromJson(Map<String, dynamic> json) :
        authenticated = json[ApiObjectProperty.authenticated],
        openScreen = json[ApiObjectProperty.openScreen],
        super.fromJson(json);
}