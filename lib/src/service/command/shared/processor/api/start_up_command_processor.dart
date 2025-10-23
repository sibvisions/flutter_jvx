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

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../../../../flutter_ui.dart';
import '../../../../../model/command/api/startup_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_startup_request.dart';
import '../../../../../util/device_info.dart';
import '../../../../../util/push_util.dart';
import '../../../../api/i_api_service.dart';
import '../../../../apps/app_parameter_names.dart';
import '../../../../config/i_config_service.dart';
import '../../../../ui/i_ui_service.dart';
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

    IConfigService servConf = IConfigService();

    assert(servConf.baseUrl.value != null, "baseUrl can not be empty!");
    assert(servConf.baseUrl.value != null, "baseUrl can not be empty!");

    IUiService servUi = IUiService();

    // Close frames on (re-)start
    if (FlutterUI.getCurrentContext() != null) {
      servUi.closeJVxDialogs();
      servUi.disposeContents();
    }

    //map is already a clone
    Map<String, dynamic> mpProps = servConf.getCustomStartupParameters();
    mpProps.addAll(servConf.getTemporaryStartupParameters());

    if (PushUtil.currentToken != null) {
      mpProps[AppParameterNames.pushToken] = PushUtil.currentToken;
    }

    //can be used for push
    mpProps[AppParameterNames.packageName] = FlutterUI.packageInfo.packageName;

    //send additional debug information
    if (kDebugMode) {
      mpProps[AppParameterNames.debugMode] = "true";
    }

    BuildContext? context = FlutterUI.getEffectiveContext();

    Size? phoneSize;

    if (context != null) {
      // ignore: use_build_context_synchronously
      phoneSize = MediaQuery.maybeSizeOf(context);
    }

    ApiStartupRequest startupRequest = ApiStartupRequest(
      baseUrl: servConf.baseUrl.value!.toString(),
      requestUri: kIsWeb ? Uri.base.toString() : null,
      appMode: "full",
      applicationName: servConf.appName.value!,
      authKey: servConf.authKey.value,
      screenHeight: phoneSize?.height.toInt(),
      screenWidth: phoneSize?.width.toInt(),
      readAheadLimit: FlutterUI.readAheadLimit,
      deviceMode: (kIsWeb && !servUi.mobileOnly.value) || servUi.webOnly.value ? "mobileDesktop" : "mobile",
      darkMode: MediaQuery.platformBrightnessOf(FlutterUI.getEffectiveContext()!) == Brightness.dark,
      username: command.username ?? servConf.username.value,
      password: command.password ?? servConf.password.value,
      langCode: servConf.userLanguage.value ?? servConf.getPlatformLocale(),
      timeZoneCode: servConf.getPlatformTimeZone()!,
      technology: deviceInfo.technology,
      osName: deviceInfo.osName,
      osVersion: deviceInfo.osVersion,
      appVersion: deviceInfo.appVersion,
      deviceType: deviceInfo.deviceType,
      deviceTypeModel: deviceInfo.deviceTypeModel,
      deviceId: deviceInfo.deviceId,
      installId: await servConf.getConfigHandler().installId(),
      serverVersion: FlutterUI.supportedServerVersion,
      customProperties: mpProps.isNotEmpty ? mpProps : null,
    );

    return IApiService().sendRequest(startupRequest).then((value) {
      // Only clear on successful startup (will work with retry)
      IConfigService().getTemporaryStartupParameters().clear();
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
  }
}
