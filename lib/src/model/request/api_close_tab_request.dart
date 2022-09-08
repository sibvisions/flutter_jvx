import '../../service/api/shared/api_object_property.dart';
import 'i_session_request.dart';

/// Request to notify the server which tab on a tab-set panel is being closed/deleted
class ApiCloseTabRequest extends ISessionRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Component name of the tab-set panel
  final String componentName;

  /// Index of the closed tab
  final int index;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiCloseTabRequest({
    required this.index,
    required this.componentName,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        ApiObjectProperty.componentId: componentName,
        ApiObjectProperty.index: index,
      };
}
