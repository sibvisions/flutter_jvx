import 'package:yaml/yaml.dart';

class ServerConfig {
  String baseUrl;
  String appName;
  String appMode;
  String? username;
  String? password;

  bool get isProd => appMode == 'prod';

  bool get isFull => appMode == 'full';

  bool get isPreview => appMode == 'preview' || appMode == '';

  ServerConfig(
      {required this.baseUrl,
      required this.appName,
      this.appMode = 'full',
      this.username,
      this.password});

  Map<String, dynamic> toJson() => <String, dynamic>{
        'baseUrl': baseUrl,
        'appName': appName,
        'appMode': appMode,
      };

  ServerConfig.fromJson({required Map<String, dynamic> map})
      : baseUrl = map['baseUrl'],
        appName = map['appName'],
        appMode = map['appMode'];

  ServerConfig.fromYaml({required YamlMap map})
      : baseUrl = map['baseUrl'],
        appName = map['appName'],
        appMode = map['appMode'];
}
