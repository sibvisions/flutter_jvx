import '../api_object_property.dart';

class StartUpRequest {
  final String applicationName;
  final String deviceMode;


  StartUpRequest({
    required this.deviceMode,
    required this.applicationName,
  });

  StartUpRequest.fromJson({required Map<String, dynamic> json}) :
        deviceMode = json[ApiObjectProperty.deviceMode],
        applicationName = json[ApiObjectProperty.applicationName];

  Map<String, dynamic> toJson() => {
    ApiObjectProperty.deviceMode : deviceMode,
    ApiObjectProperty.applicationName : applicationName
  };
}