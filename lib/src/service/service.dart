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

import 'dart:async';

import 'package:get_it/get_it.dart';

GetIt services = GetIt.I;

/// Defines the base construct of a service.
abstract interface class Service {
  /// Clears/reset the service based on the provided [reason]
  /// and prepare it for reinitialization.
  FutureOr<void> clear(ClearReason reason);
}

enum ClearReason {
  /// Full app stop (no restart planned).
  DEFAULT,

  /// Full app restart.
  RESTART,

  /// User log out.
  LOGOUT,
  ;

  bool isFull() {
    return this == DEFAULT || this == RESTART;
  }
}
