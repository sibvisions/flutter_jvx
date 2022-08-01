import '../../service/api/shared/api_object_property.dart';
import 'i_api_request.dart';

/// Request to send when a button has been pressed.
class ApiPressButtonRequest extends IApiRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Session id
  final String clientId;

  /// Component name of the button clicked
  final String componentName;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiPressButtonRequest({
    required this.componentName,
    required this.clientId,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Map<String, dynamic> toJson() => {
        ApiObjectProperty.clientId: clientId,
        ApiObjectProperty.componentId: componentName,
      };
}
