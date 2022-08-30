import 'server_config.dart';
import 'ui_config.dart';
import 'version_config.dart';

class AppConfig {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final String? title;
  final int? requestTimeout;

  final UiConfig? uiConfig;
  final ServerConfig? serverConfig;
  final VersionConfig? versionConfig;

  final Map<String, dynamic>? startupParameters;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const AppConfig({
    this.title,
    this.requestTimeout,
    this.uiConfig,
    this.serverConfig,
    this.versionConfig,
    this.startupParameters,
  });

  const AppConfig.empty()
      : this(
          title: "JVx Mobile",
          requestTimeout: 10,
          uiConfig: const UiConfig.empty(),
          serverConfig: const ServerConfig.empty(),
          versionConfig: const VersionConfig.empty(),
        );

  AppConfig.fromJson({required Map<String, dynamic> json})
      : this(
          title: json["title"],
          requestTimeout: json["requestTimeout"],
          uiConfig: json["uiConfig"] != null ? UiConfig.fromJson(json: json["uiConfig"]) : null,
          serverConfig: json["serverConfig"] != null ? ServerConfig.fromJson(json: json["serverConfig"]) : null,
          versionConfig: json["versionConfig"] != null ? VersionConfig.fromJson(json: json["versionConfig"]) : null,
          startupParameters: json["startupParameters"],
        );

  AppConfig merge(AppConfig? other) {
    if (other == null) return this;

    return AppConfig(
      title: other.title ?? title,
      requestTimeout: other.requestTimeout ?? requestTimeout,
      uiConfig: uiConfig?.merge(other.uiConfig) ?? other.uiConfig,
      serverConfig: serverConfig?.merge(other.serverConfig) ?? other.serverConfig,
      versionConfig: versionConfig?.merge(other.versionConfig) ?? other.versionConfig,
      startupParameters: (startupParameters ?? {})..addAll(other.startupParameters ?? {}),
    );
  }
}
