class ServerConfig {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final String? baseUrl;
  final String? appName;
  final String? username;
  final String? password;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const ServerConfig({
    this.baseUrl,
    this.appName,
    this.username,
    this.password,
  });

  const ServerConfig.empty() : this();

  ServerConfig.fromJson(Map<String, dynamic> json)
      : this(
          baseUrl: json['baseUrl'],
          appName: json['appName'],
          username: json['username'],
          password: json['password'],
        );

  ServerConfig merge(ServerConfig? other) {
    if (other == null) return this;

    return ServerConfig(
      baseUrl: other.baseUrl ?? baseUrl,
      appName: other.appName ?? appName,
      username: other.username ?? username,
      password: other.password ?? password,
    );
  }

  Map<String, dynamic> toJson() => {
        'baseUrl': baseUrl,
        'appName': appName,
        'username': username,
        'password': password,
      };
}
