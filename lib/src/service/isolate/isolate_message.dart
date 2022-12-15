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

import 'dart:isolate';

/// Base class for all messages to the API isolate.
/// [T] indicates what return value is expected
/// from the execution of the message.
abstract class IsolateMessage<T> {
  // TODO remove every wrapper message and co&kg
  sendResponse({required T? pResponse, required SendPort pSendPort}) {
    pSendPort.send(pResponse);
  }
}
