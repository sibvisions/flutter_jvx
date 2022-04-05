import 'package:flutter_client/src/model/api/requests/i_api_request.dart';

import '../api_object_property.dart';

/// Request to update the available screen size to the app
class ApiDeviceStatusRequest implements IApiRequest {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Session id
  final String clientId;
  /// Available width of the device for workscreens
  final double screenWidth;
  /// Available height of the device for workscreens
  final double screenHeight;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiDeviceStatusRequest({
    required this.clientId,
    required this.screenWidth,
    required this.screenHeight
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Map<String, dynamic> toJson() => {
    ApiObjectProperty.clientId : clientId,
    ApiObjectProperty.screenHeight : screenHeight,
    ApiObjectProperty.screenWidth : screenWidth
  };

}