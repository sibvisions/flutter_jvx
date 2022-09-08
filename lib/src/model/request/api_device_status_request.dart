import '../../service/api/shared/api_object_property.dart';
import 'i_session_request.dart';

/// Request to update the available screen size to the app
class ApiDeviceStatusRequest extends ISessionRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Available width of the device for workscreens
  final double screenWidth;

  /// Available height of the device for workscreens
  final double screenHeight;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiDeviceStatusRequest({
    required this.screenWidth,
    required this.screenHeight,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        ApiObjectProperty.screenHeight: screenHeight,
        ApiObjectProperty.screenWidth: screenWidth,
      };
}
