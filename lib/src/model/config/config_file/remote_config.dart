import 'package:flutter_client/src/model/config/api/url_config.dart';

class RemoteConfig {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final int indexOfUsingUrlConfig;

  final List<UrlConfig>? devUrlConfigs;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  RemoteConfig({
    required this.indexOfUsingUrlConfig,
    required this.devUrlConfigs,
  });

  RemoteConfig.fromJson({required Map<String, dynamic> json})
      : indexOfUsingUrlConfig = json["indexOfUsingUrlConfig"] ?? 0,
        devUrlConfigs = json["devUrlConfigs"] != null ? parseUrlConfigsFromJson(json: json["devUrlConfigs"]) : null;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  static List<UrlConfig> parseUrlConfigsFromJson({required List<dynamic> json}) {
    return json.map((e) => UrlConfig.fromJson(json: e)).toList();
  }
}
