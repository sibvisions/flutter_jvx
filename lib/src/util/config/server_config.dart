class ServerConfig {
  String baseUrl;
  String appName;
  String appMode;

  ServerConfig(
      {required this.baseUrl, required this.appName, this.appMode = 'full'});

  Map<String, dynamic> toJson() => <String, dynamic>{
        'baseUrl': baseUrl,
        'appName': appName,
        'appMode': appMode,
      };
}
