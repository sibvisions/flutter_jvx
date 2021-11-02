class StartUpRequest {
  final String applicationName;


  StartUpRequest({
    required this.applicationName,
  });

  StartUpRequest.fromJson({required Map<String, dynamic> json}) :
      applicationName = json[_PStartup.applicationName];

  Map<String, dynamic> toJson() => {
    _PStartup.applicationName : applicationName
  };
}


class _PStartup {
  static const applicationName = "applicationName";
}