import '../api_object_property.dart';

class StartUpRequest {
  final String applicationName;
  final String deviceMode;
  final double? screenWidth;
  final double? screenHeight;


  StartUpRequest({
    required this.deviceMode,
    required this.applicationName,
    this.screenHeight,
    this.screenWidth
  });

  Map<String, dynamic> toJson() => {
    ApiObjectProperty.deviceMode : deviceMode,
    ApiObjectProperty.applicationName : applicationName
  };
}