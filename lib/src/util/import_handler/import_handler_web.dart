/*
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'package:flutter_web_plugins/flutter_web_plugins.dart' as web_plugins;
import 'package:web_socket_channel/html.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../flutter_ui.dart';

/// Web "Implementation" of [ImportHandler]
class ImportHandler {
  static void setHashUrlStrategy() {
    web_plugins.setUrlStrategy(const FixedHashUrlStrategy());
  }

  static WebSocketChannel getWebSocketChannel(Uri uri, Map<String, dynamic>? headers) =>
      HtmlWebSocketChannel.connect(uri);
}

class FixedHashUrlStrategy extends web_plugins.HashUrlStrategy {
  final web_plugins.PlatformLocation _platformLocation;

  // ignore: use_super_parameters
  const FixedHashUrlStrategy([this._platformLocation = const web_plugins.BrowserPlatformLocation()])
      : super(_platformLocation);

  @override
  String prepareExternalUrl(String internalUrl) {
    // Workaround for https://github.com/flutter/flutter/issues/116415
    return "${_platformLocation.pathname}${_platformLocation.search}${internalUrl.isEmpty ? '' : '#$internalUrl'}";
  }

  @override
  void pushState(Object? state, String title, String url) {
    super.pushState(state, title, url);

    //otherwise, title will be wrong
    FlutterUI.updateTitle();
  }

  @override
  void replaceState(Object? state, String title, String url) {
    super.replaceState(state, title, url);

    //otherwise, title will be wrong
    FlutterUI.updateTitle();
  }

}
