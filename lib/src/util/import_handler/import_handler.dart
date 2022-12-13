/* Copyright 2022 SIB Visions GmbH
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

import 'dart:async';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'import_handler_stub.dart'
    if (dart.library.html) 'import_handler_web.dart'
    if (dart.library.io) 'import_handler_mobile.dart' as platform;

FutureOr<void> initTimeZones() {
  return platform.ImportHandler.initializeTimeZones();
}

void fixUrlStrategy() {
  platform.ImportHandler.setHashUrlStrategy();
}

WebSocketChannel createWebSocket(Uri uri, Map<String, dynamic> headers) =>
    platform.ImportHandler.getWebSocketChannel(uri, headers);
