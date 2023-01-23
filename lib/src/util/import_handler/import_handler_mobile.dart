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

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Mobile "Implementation" of [ImportHandler]
class ImportHandler {
  static void setHashUrlStrategy() {
    // No-op.
  }

  static WebSocketChannel getWebSocketChannel(Uri uri, Map<String, dynamic>? headers) =>
      IOWebSocketChannel.connect(uri, headers: headers);
}
