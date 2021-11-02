import 'package:flutter_jvx/src/models/config/i_config_api_url.dart';
import 'package:flutter_jvx/src/util/mixin/base_url_builder.dart';

class ConfigApiUrlStatic with BaseUrlBuilder implements IConfigApiUrl {

  String pHost;
  String pPath;

  bool pIsHttps;
  int pPort;

  ConfigApiUrlStatic({
    required this.pIsHttps,
    required this.pHost,
    required this.pPort,
    required this.pPath
  });

  @override
  String get basePath => getBaseUrl(https: isHttps, host: host, port: port, pathToService: path);

  @override
  String get host => pHost;

  @override
  bool get isHttps => pIsHttps;

  @override
  String get path => pPath;

  @override
  int get port => pPort;
}