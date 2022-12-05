import 'package:flutter_web_plugins/flutter_web_plugins.dart' as web_plugins;

class FixedHashUrlStrategy extends web_plugins.HashUrlStrategy {
  final web_plugins.PlatformLocation _platformLocation;

  const FixedHashUrlStrategy([this._platformLocation = const web_plugins.BrowserPlatformLocation()])
      : super(_platformLocation);

  @override
  String prepareExternalUrl(String internalUrl) {
    // Workaround for https://github.com/flutter/flutter/issues/116415
    return "${_platformLocation.pathname}${_platformLocation.search}${internalUrl.isEmpty ? '' : '#$internalUrl'}";
  }
}

void setHashUrlStrategy() {
  web_plugins.setUrlStrategy(const FixedHashUrlStrategy());
}
