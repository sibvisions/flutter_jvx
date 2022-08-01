import '../../service/api/shared/api_object_property.dart';
import 'i_api_request.dart';

/// Request to set the value of an unbound(no-dataProvider) component
class ApiSetValueRequest extends IApiRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Session id
  final String clientId;

  /// Name of the component from which the value is set
  final String componentName;

  /// Value to be set
  final dynamic value;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiSetValueRequest({required this.componentName, required this.value, required this.clientId});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Map<String, dynamic> toJson() => {
        ApiObjectProperty.clientId: clientId,
        ApiObjectProperty.componentId: componentName,
        ApiObjectProperty.value: value
      };
}
