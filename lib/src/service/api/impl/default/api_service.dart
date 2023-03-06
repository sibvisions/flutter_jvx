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

import '../../../../model/command/base_command.dart';
import '../../../../model/request/api_request.dart';
import '../../i_api_service.dart';
import '../../shared/i_controller.dart';
import '../../shared/i_repository.dart';

///
/// Will execute all actions on the main Isolate
///
class ApiService implements IApiService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Executes remote requests
  IRepository repository;

  /// Processes responses into commands
  IController? controller;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes a Instance where [repository] and [controller] are null
  /// and need to be set before any request can be sent.
  ApiService.create(this.repository);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<List<BaseCommand>> sendRequest(ApiRequest request, [bool? retryRequest]) {
    if (repository == null) throw Exception("Repository not initialized");
    if (controller == null) throw Exception("Controller not initialized");
    return repository.sendRequest(request, retryRequest).then((value) => controller!.processResponse(value));
  }

  @override
  IRepository getRepository() {
    return repository;
  }

  @override
  void setRepository(IRepository pRepository) {
    repository = pRepository;
  }

  @override
  void setController(IController pController) {
    controller = pController;
  }

  @override
  FutureOr<void> clear(bool pFullClear) async {
    if (pFullClear) {
      await repository.stop();
      await repository.start();
    }
  }
}
