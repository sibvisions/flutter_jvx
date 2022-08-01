import '../../service/api/shared/api_object_property.dart';
import 'i_api_request.dart';

/// Request to initialize the app to the remote server
class ApiStartUpRequest extends IApiRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Name of the JVx application
  final String applicationName;

  /// Mode of the Device
  final String deviceMode;

  /// Mode of this app
  final String appMode;

  /// Total available (for workscreens) width of the screen
  final double? screenWidth;

  /// Total available (for workscreens) height of the screen
  final double? screenHeight;

  /// Name of the user
  final String? username;

  /// Password of the user
  final String? password;

  /// Auth-key from previous auto-login
  final String? authKey;

  /// Language code
  final String langCode;

  /// Custom startup parameters
  final Map<String, dynamic>? startUpParameters;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiStartUpRequest({
    required this.appMode,
    required this.deviceMode,
    required this.applicationName,
    required this.langCode,
    this.screenHeight,
    this.screenWidth,
    this.username,
    this.password,
    this.authKey,
    this.startUpParameters,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Map<String, dynamic> toJson() => {
        ApiObjectProperty.appMode: appMode,
        ApiObjectProperty.deviceMode: deviceMode,
        ApiObjectProperty.applicationName: applicationName,
        ApiObjectProperty.userName: username,
        ApiObjectProperty.password: password,
        ApiObjectProperty.screenWidth: screenWidth,
        ApiObjectProperty.screenHeight: screenHeight,
        ApiObjectProperty.authKey: authKey,
        ApiObjectProperty.langCode: langCode,
        ...?startUpParameters
      };
}
