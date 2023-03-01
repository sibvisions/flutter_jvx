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

import 'package:flutter/foundation.dart';

import '../../../../../flutter_ui.dart';
import '../../../../../model/command/api/startup_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_startup_request.dart';
import '../../../../../util/device_info.dart';
import '../../../../api/i_api_service.dart';
import '../../../../config/config_controller.dart';
import '../../../../ui/i_ui_service.dart';
import '../../i_command_processor.dart';

/// Used to process [StartupCommand], will call ApiService
class StartUpCommandProcessor implements ICommandProcessor<StartupCommand> {
  @override
  Future<List<BaseCommand>> processCommand(StartupCommand command) async {
    if (command.appName != null) {
      await ConfigController().updateAppName(command.appName!);
    }
    if (command.username != null) {
      await ConfigController().updateUsername(command.username!);
    }
    if (command.password != null) {
      await ConfigController().updatePassword(command.password!);
    }

    DeviceInfo deviceInfo = await DeviceInfo.fromPlatform();

    // Close frames on (re-)start
    if (FlutterUI.getCurrentContext() != null) {
      IUiService().closeJVxDialogs();
    }

    ApiStartUpRequest startUpRequest = ApiStartUpRequest(
      baseUrl: ConfigController().baseUrl.value!.toString(),
      requestUri: kIsWeb ? Uri.base.toString() : null,
      appMode: "full",
      applicationName: ConfigController().appName.value!,
      authKey: ConfigController().authKey.value,
      screenHeight: ConfigController().getPhoneSize()?.height.toInt(),
      screenWidth: ConfigController().getPhoneSize()?.width.toInt(),
      readAheadLimit: 100,
      deviceMode: (kIsWeb && !IUiService().mobileOnly.value) || IUiService().webOnly.value ? "mobileDesktop" : "mobile",
      username: command.username,
      password: command.password,
      langCode: ConfigController().userLanguage.value ?? ConfigController().getPlatformLocale(),
      timeZoneCode: ConfigController().getPlatformTimeZone()!,
      technology: deviceInfo.technology,
      osName: deviceInfo.osName,
      osVersion: deviceInfo.osVersion,
      appVersion: deviceInfo.appVersion,
      deviceType: deviceInfo.deviceType,
      deviceTypeModel: deviceInfo.deviceTypeModel,
      deviceId: deviceInfo.deviceId,
      serverVersion: FlutterUI.supportedServerVersion,
      startUpParameters: ConfigController().getStartupParameters(),
    );

    return IApiService().sendRequest(startUpRequest);
  }
}
