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

import 'package:flutter/widgets.dart';
import 'package:universal_io/io.dart';

import '../../../mask/error/server_session_expired_dialog.dart';
import '../../../model/api_interaction.dart';
import '../../../model/request/api_request.dart';

/// The interface declaring all possible requests to the mobile server.
abstract class IRepository {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Whether or not the user has explicitly cancelled the [ServerSessionExpiredDialog] dialog.
  ///
  /// Normally requests throw an error if they need a client id. When a user cancels the [ServerSessionExpiredDialog] dialog,
  /// we no longer have a client id but must support him still clicking stuff.
  final ValueNotifier<bool> cancelledSessionExpired = ValueNotifier(false);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes the repository, has to be closed with [stop]
  Future<void> start();

  /// Stops the repository
  @mustCallSuper
  Future<void> stop() async {
    cancelledSessionExpired.value = false;
  }

  /// Returns if the repository has already been closed with [stop]
  bool isStopped();

  /// Returns all saved headers used for requests
  Map<String, String> getHeaders();

  /// Returns all saved cookies used for requests
  Set<Cookie> getCookies();

  /// Sets new cookies used for requests
  void setCookies(Set<Cookie> pCookies);

  /// Sends [pRequest] via a long-running client and throws an exception if the request fails.
  Future<ApiInteraction> sendRequest(ApiRequest pRequest, [bool? retryRequest]);
}
