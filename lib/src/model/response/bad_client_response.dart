import '../../service/api/shared/api_object_property.dart';
import 'api_response.dart';

class BadClientResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final String? info;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  BadClientResponse({
    this.info,
    required super.name,
  });

  BadClientResponse.fromJson(super.json)
      : info = json[ApiObjectProperty.info],
        super.fromJson();
}
