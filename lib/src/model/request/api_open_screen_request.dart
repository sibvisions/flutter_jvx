import '../../service/api/shared/api_object_property.dart';
import 'i_api_request.dart';

/// Request to open a new work screen
class ApiOpenScreenRequest extends IApiRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Session id
  final String clientId;

  /// Id of the menuItem clicked
  final String? screenLongName;

  /// Id of the menuItem clicked
  final String? screenClassName;

  /// If the screen should only be closed manually
  final bool manualClose;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiOpenScreenRequest({this.screenLongName, this.screenClassName, required this.clientId, required this.manualClose});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Map<String, dynamic> toJson() => {
        ApiObjectProperty.clientId: clientId,
        ApiObjectProperty.componentId: screenLongName,
        ApiObjectProperty.className: screenClassName,
        ApiObjectProperty.manualClose: manualClose
      };
}
