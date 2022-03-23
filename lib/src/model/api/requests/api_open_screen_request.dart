import 'package:flutter_client/src/model/api/requests/api_request.dart';

import '../api_object_property.dart';

/// Request to open a new work screen
class ApiOpenScreenRequest extends ApiRequest {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Session id
  final String clientId;
  /// Id of the menuItem clicked
  final String componentId;
  /// If the screen should only be closed manually
  final bool manualClose;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiOpenScreenRequest({
    required this.componentId,
    required this.clientId,
    required this.manualClose
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Map<String, dynamic> toJson() => {
    ApiObjectProperty.clientId: clientId,
    ApiObjectProperty.componentId: componentId,
    ApiObjectProperty.manualClose: manualClose
  };
}