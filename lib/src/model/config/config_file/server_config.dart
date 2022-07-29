enum AppMode { full, production, preview }

class ServerConfig {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final String? baseUrl;
  final AppMode appMode;
  final String? appName;
  final String? username;
  final String? password;

  bool get isProd => appMode == AppMode.production;

  bool get isFull => appMode == AppMode.full;

  bool get isPreview => appMode == AppMode.preview;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const ServerConfig({
    this.baseUrl,
    this.appName,
    this.appMode = AppMode.full,
    this.username,
    this.password,
  });

  const ServerConfig.empty() : this();

  ServerConfig.fromJson({required Map<String, dynamic> json})
      : this(
          baseUrl: json['baseUrl'],
          appMode: AppMode.values.byName(json['appMode'] as String),
          appName: json['appName'],
          username: json['username'],
          password: json['password'],
        );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'baseUrl': baseUrl,
        'appMode': appMode,
        'appName': appName,
        'username': username,
        'password': password,
      };
}
