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
  final int? screenWidth;

  /// Total available (for workscreens) height of the screen
  final int? screenHeight;

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

  /// How many records the app should fetch ahead
  int? readAheadLimit;

  /// Unique id of this device.
  String? deviceId;

  /// The technology of this app.
  String? technology;

  /// The os name this app runs on.
  String? osName;

  /// The os version this app runs on.
  String? osVersion;

  /// The app version.
  String? appVersion;

  /// The type of device this app runs on.
  String? deviceType;

  /// The device type model this app runs on.
  String? deviceTypeModel;

  /// If the server must create a new session
  bool? forceNewSession;
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
    this.readAheadLimit,
    this.deviceId,
    this.technology,
    this.osName,
    this.osVersion,
    this.appVersion,
    this.deviceType,
    this.deviceTypeModel,
    this.forceNewSession,
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
        ApiObjectProperty.readAheadLimit: readAheadLimit,
        ApiObjectProperty.deviceId: deviceId,
        ApiObjectProperty.technology: technology,
        ApiObjectProperty.osName: osName,
        ApiObjectProperty.osVersion: osVersion,
        ApiObjectProperty.appVersion: appVersion,
        ApiObjectProperty.deviceType: deviceType,
        ApiObjectProperty.deviceTypeModel: deviceTypeModel,
        ApiObjectProperty.forceNewSession: forceNewSession,
        ...?startUpParameters
      };
}
