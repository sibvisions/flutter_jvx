import '../../service/api/shared/api_object_property.dart';
import 'session_request.dart';

/// Request to open a new work screen
class ApiOpenScreenRequest extends SessionRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Id of the menuItem clicked
  final String? screenLongName;

  /// Id of the menuItem clicked
  final String? screenClassName;

  /// If the screen should only be closed manually
  final bool manualClose;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiOpenScreenRequest({
    this.screenLongName,
    this.screenClassName,
    required this.manualClose,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        ApiObjectProperty.componentId: screenLongName,
        ApiObjectProperty.className: screenClassName,
        ApiObjectProperty.manualClose: manualClose
      };
}
