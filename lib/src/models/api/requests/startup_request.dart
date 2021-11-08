class StartUpRequest {
  final String applicationName;
  final String deviceMode;


  StartUpRequest({
    required this.deviceMode,
    required this.applicationName,
  });

  StartUpRequest.fromJson({required Map<String, dynamic> json}) :
      deviceMode = json[_PStartup.deviceMode],
      applicationName = json[_PStartup.applicationName];

  Map<String, dynamic> toJson() => {
    _PStartup.deviceMode : deviceMode,
    _PStartup.applicationName : applicationName
  };
}


class _PStartup {
  static const deviceMode = "deviceMode";
  static const applicationName = "applicationName";
}