import '../api_object_property.dart';

class StartUpRequest {
  final String applicationName;
  final String deviceMode;
  final double? screenWidth;
  final double? screenHeight;
  final String appMode;


  StartUpRequest({
    required this.appMode,
    required this.deviceMode,
    required this.applicationName,
    this.screenHeight,
    this.screenWidth
  });

  Map<String, dynamic> toJson() => {
    ApiObjectProperty.appMode: appMode,
    ApiObjectProperty.deviceMode : deviceMode,
    ApiObjectProperty.applicationName : applicationName
  };
}