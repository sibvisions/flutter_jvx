import '../../service/api/shared/api_object_property.dart';
import 'i_api_request.dart';

class ApiCloseScreenRequest implements IApiRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Session id
  final String clientId;

  /// Name of the screen to close
  final String screenName;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiCloseScreenRequest({
    required this.clientId,
    required this.screenName,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Map<String, dynamic> toJson() => {
        ApiObjectProperty.clientId: clientId,
        ApiObjectProperty.componentId: screenName,
      };
}
