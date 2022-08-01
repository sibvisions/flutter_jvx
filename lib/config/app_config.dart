import 'server_config.dart';
import 'ui_config.dart';
import 'version_config.dart';

class AppConfig {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final String title;
  final bool package;
  final int requestTimeout;

  final UiConfig uiConfig;
  final ServerConfig serverConfig;
  final VersionConfig versionConfig;

  final Map<String, dynamic>? startupParameters;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  AppConfig({
    this.title = "JVx Mobile",
    this.uiConfig = const UiConfig.empty(),
    this.serverConfig = const ServerConfig.empty(),
    this.versionConfig = const VersionConfig.empty(),
    this.package = false,
    this.requestTimeout = 10,
    this.startupParameters,
  });

  AppConfig.fromJson({required Map<String, dynamic> json})
      : this(
          title: json["title"] ?? "JVx Mobile",
          package: json["package"] ?? false,
          requestTimeout: json["requestTimeout"] ?? 10,
          uiConfig: json["uiConfig"] != null ? UiConfig.fromJson(json: json["uiConfig"]) : const UiConfig.empty(),
          serverConfig: json["serverConfig"] != null
              ? ServerConfig.fromJson(json: json["serverConfig"])
              : const ServerConfig.empty(),
          versionConfig: json["versionConfig"] != null
              ? VersionConfig.fromJson(json: json["versionConfig"])
              : const VersionConfig.empty(),
          startupParameters: json["startupParameters"],
        );
}
