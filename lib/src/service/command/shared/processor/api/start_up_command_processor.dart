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
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../../../../flutter_ui.dart';
import '../../../../../model/command/api/set_parameter_command.dart';
import '../../../../../model/command/api/startup_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_startup_request.dart';
import '../../../../../util/device_info.dart';
import '../../../../../util/push_util.dart';
import '../../../../api/i_api_service.dart';
import '../../../../config/i_config_service.dart';
import '../../../../ui/i_ui_service.dart';
import '../../../i_command_service.dart';
import '../../i_command_processor.dart';

/// Used to process [StartupCommand], will call ApiService
class StartupCommandProcessor extends ICommandProcessor<StartupCommand> {
  @override
  Future<void> beforeProcessing(StartupCommand command, BaseCommand? origin) async {
    IUiService().getAppManager()?.onInitStartup();
  }

  @override
  Future<List<BaseCommand>> processCommand(StartupCommand command, BaseCommand? origin) async {
    DeviceInfo deviceInfo = await DeviceInfo.fromPlatform();

    // Close frames on (re-)start
    if (FlutterUI.getCurrentContext() != null) {
      IUiService().closeJVxDialogs();
      IUiService().disposeContents();
    }

    Size? phoneSize = MediaQuery.maybeSizeOf(FlutterUI.getEffectiveContext()!);

    assert(IConfigService().baseUrl.value != null, "baseUrl can not be empty!");
    assert(IConfigService().baseUrl.value != null, "baseUrl can not be empty!");

    ApiStartupRequest startupRequest = ApiStartupRequest(
      baseUrl: IConfigService().baseUrl.value!.toString(),
      requestUri: kIsWeb ? Uri.base.toString() : null,
      appMode: "full",
      applicationName: IConfigService().appName.value!,
      authKey: IConfigService().authKey.value,
      screenHeight: phoneSize?.height.toInt(),
      screenWidth: phoneSize?.width.toInt(),
      readAheadLimit: FlutterUI.readAheadLimit,
      deviceMode: (kIsWeb && !IUiService().mobileOnly.value) || IUiService().webOnly.value ? "mobileDesktop" : "mobile",
      darkMode: MediaQuery.platformBrightnessOf(FlutterUI.getEffectiveContext()!) == Brightness.dark,
      username: command.username ?? IConfigService().username.value,
      password: command.password ?? IConfigService().password.value,
      langCode: IConfigService().userLanguage.value ?? IConfigService().getPlatformLocale(),
      timeZoneCode: IConfigService().getPlatformTimeZone()!,
      technology: deviceInfo.technology,
      osName: deviceInfo.osName,
      osVersion: deviceInfo.osVersion,
      appVersion: deviceInfo.appVersion,
      deviceType: deviceInfo.deviceType,
      deviceTypeModel: deviceInfo.deviceTypeModel,
      deviceId: deviceInfo.deviceId,
      serverVersion: FlutterUI.supportedServerVersion,
      customProperties: IConfigService().getCustomStartupProperties(),
    );

    return IApiService().sendRequest(startupRequest).then((value) {
      // Only clear on successful startup.
      IConfigService().getCustomStartupProperties().clear();
      return value;
    });
  }

  @override
  Future<void> afterProcessing(StartupCommand command, BaseCommand? origin) async {
    FlutterUI.clearHistory();
  }

  @override
  Future<void> onFinish(StartupCommand command) async {
    FlutterUI.clearLocationHistory();
    IUiService().getAppManager()?.onSuccessfulStartup();

    unawaited(_sendPushToken());
  }

  Future<void> _sendPushToken() async {
    String? pushToken = await PushUtil.retrievePushToken();
    if (pushToken != null) {
      try {
        await ICommandService().sendCommand(
          SetParameterCommand(
            parameter: {PushUtil.parameterPushToken: pushToken},
            reason: "Send PushToken after startup",
          ),
        );

        var state = FlutterUI.of(FlutterUI.getEffectiveContext()!);
        var data = state.tappedNotificationPayloads.value.lastOrNull ?? PushUtil.notificationWhichLaunchedApp;
        if (data != null) {
          await ICommandService().sendCommand(
            SetParameterCommand(
              parameter: {PushUtil.parameterPushData: jsonEncode(data)},
              reason: "Send PushData after startup",
            ),
          );
        }
        // Clear on success
        state.tappedNotificationPayloads.value.clear();
        PushUtil.notificationWhichLaunchedApp = null;
      } catch (e, stack) {
        FlutterUI.log.w("Failed to send push token/data to server", error: e, stackTrace: stack);
      }
    }
  }
}
