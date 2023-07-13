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

import '../../../../../model/command/api/device_status_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_device_status_request.dart';
import '../../../../api/i_api_service.dart';
import '../../../../config/i_config_service.dart';
import '../../../../ui/i_ui_service.dart';
import '../../i_command_processor.dart';

/// Calls [IApiService] deviceStatus and [ConfigService] for current clientId
class DeviceStatusCommandProcessor extends ICommandProcessor<DeviceStatusCommand> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiDeviceStatusRequest? lastSentRequest;

  @override
  Future<List<BaseCommand>> processCommand(DeviceStatusCommand command, BaseCommand? origin) async {
    if (IUiService().clientId.value != null && !IConfigService().offline.value) {
      ApiDeviceStatusRequest deviceStatusRequest = ApiDeviceStatusRequest(
        screenWidth: command.screenWidth,
        screenHeight: command.screenHeight,
        darkMode: command.darkMode,
      );
      if (deviceStatusRequest.hasNewProperties(lastSentRequest)) {
        lastSentRequest = lastSentRequest?.merge(deviceStatusRequest) ?? deviceStatusRequest;
        return IApiService().sendRequest(deviceStatusRequest);
      }
    }
    return [];
  }
}
