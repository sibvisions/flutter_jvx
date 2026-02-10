/*
 * Copyright 2026 SIB Visions GmbH
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

import 'package:universal_io/io.dart';

import '../../../../model/api_interaction.dart';
import '../../../../model/request/api_request.dart';
import '../i_repository.dart';

class NoOpRepository extends IRepository {

  @override
  Future<void> start() async {
  }

  Future<void> initDataBooks() async {
  }

  @override
  bool isStopped() {
    return true;
  }

  @override
  Set<Cookie> getCookies() => {};

  @override
  void setCookies(Set<Cookie> pCookies) => {};

  @override
  Map<String, String> getHeaders() => {};

  @override
  Future<ApiInteraction> sendRequest(ApiRequest pRequest, [bool? retryRequest]) async {
    return Future.value(ApiInteraction(responses: []));
  }

}
