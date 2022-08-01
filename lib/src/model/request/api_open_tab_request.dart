import '../../service/api/shared/api_object_property.dart';
import 'i_api_request.dart';

/// Request to notify the server which tab on a tab-set panel is now selected
class ApiOpenTabRequest extends IApiRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Current session id
  final String clientId;

  /// Component name of the tab-set panel
  final String componentName;

  /// Index of the closed tab
  final int index;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiOpenTabRequest({required this.index, required this.componentName, required this.clientId});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Map<String, dynamic> toJson() => {
        ApiObjectProperty.clientId: clientId,
        ApiObjectProperty.componentId: componentName,
        ApiObjectProperty.index: index
      };
}
