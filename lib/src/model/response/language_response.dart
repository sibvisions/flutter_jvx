import '../../service/api/shared/api_object_property.dart';
import 'api_response.dart';

class LanguageResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Lang code of the app
  final String langCode;

  /// Time zone code of the app
  final String? timeZoneCode;

  final String? languageResource;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  LanguageResponse({
    required this.langCode,
    this.timeZoneCode,
    this.languageResource,
    required super.name,
  });

  LanguageResponse.fromJson(super.json)
      : langCode = json[ApiObjectProperty.langCode],
        timeZoneCode = json[ApiObjectProperty.timeZoneCode],
        languageResource = json[ApiObjectProperty.languageResource],
        super.fromJson();

  @override
  String toString() {
    return 'LanguageResponse{langCode: $langCode, timeZoneCode: $timeZoneCode, languageResource: $languageResource}';
  }
}
