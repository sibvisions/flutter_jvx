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

import '../../model/command/base_command.dart';
import '../../model/request/api_request.dart';
import '../service.dart';
import 'shared/i_controller.dart';
import 'shared/i_repository.dart';

abstract class IApiService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  factory IApiService() => services<IApiService>();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Any API Request will be sent to an [IRepository] to execute the request
  /// after which it will be processed to [BaseCommand]s in an [IController]
  Future<List<BaseCommand>> sendRequest(ApiRequest request, [bool? retryRequest]);

  IRepository? getRepository();

  void setRepository(IRepository pRepository);

  void setController(IController pController);

  /// Basically resets the service
  FutureOr<void> clear(bool pFullClear);
}
