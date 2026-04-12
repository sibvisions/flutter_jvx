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
import '../../../service.dart';
import '../../i_api_service.dart';
import '../../shared/i_controller.dart';
import '../../shared/i_repository.dart';

/// Handles the API to the server and manages the [IRepository].
class ApiService implements IApiService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Executes remote requests
  IRepository _repository;

  /// Processes responses into commands
  IController? _controller;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes an instance where [_repository] and [_controller] are `null`
  /// and need to be set before any request can be sent.
  ApiService.create(this._repository);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<List<BaseCommand>> sendRequest(ApiRequest request, [bool? retryRequest]) {
    if (_controller == null) throw Exception("Controller not initialized");
    
    return _repository.sendRequest(request, retryRequest).then((value) => _controller!.processResponse(value));
  }

  @override
  IRepository getRepository() {
    return _repository;
  }

  @override
  void setRepository(IRepository repository) {
    _repository = repository;
  }

  @override
  void setController(IController controller) {
    _controller = controller;
  }

  @override
  FutureOr<void> clear(ClearReason reason) async {
    if (reason.isFull()) {
      //Stop is enough because a restart will set a new repository
      //and simple stopp will also trigger a new repository "later"
      await _repository.stop();
    }
  }
}
