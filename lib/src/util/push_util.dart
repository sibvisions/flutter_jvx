/*
 * Copyright 2023 SIB Visions GmbH
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
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push/push.dart';

import '../config/server_config.dart';
import '../flutter_ui.dart';
import '../model/command/api/set_parameter_command.dart';
import '../service/apps/app.dart';
import '../service/apps/app_parameter_names.dart';
import '../service/apps/i_app_service.dart';
import '../service/command/i_command_service.dart';
import '../service/config/i_config_service.dart';
import '../service/ui/i_ui_service.dart';
import 'jvx_logger.dart';
import 'parse_util.dart';

abstract class PushUtil {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  static ValueNotifier<List<Map<String?, Object?>>>? tappedNotificationPayloads;
  static ValueNotifier<List<RemoteMessage>>? messagesReceived;
  static ValueNotifier<List<RemoteMessage>>? backgroundMessagesReceived;

  /// the local notifications plugin instance
  static FlutterLocalNotificationsPlugin localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// the current push token
  static String? currentToken;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes push handling
  static Future<void> init() async {
    if (tappedNotificationPayloads != null) {
      tappedNotificationPayloads!.value.clear();
    }
    else {
      tappedNotificationPayloads = ValueNotifier([]);
    }

    if (messagesReceived != null) {
      messagesReceived!.value.clear();
    }
    else {
      messagesReceived = ValueNotifier([]);
    }

    if (backgroundMessagesReceived != null) {
      backgroundMessagesReceived!.value.clear();
    }
    else {
      backgroundMessagesReceived = ValueNotifier([]);
    }

    var platform = localNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (platform != null) {
      AndroidNotificationChannel fallbackChannel = AndroidNotificationChannel(
        'fcm_fallback_notification_channel',
        'Notifications',
        importance: Importance.max,
      );

      List<AndroidNotificationChannel>? list = await platform.getNotificationChannels();

      if (list != null) {
        for (int i = 0; i < list.length; i++) {
          if (fallbackChannel.id == list[i].id) {
            if (list[i].importance != fallbackChannel.importance) {
              FlutterUI.log.d("Delete fallback notification channel!");
              await platform.deleteNotificationChannel(channelId: list[i].id);
            }
          }
        }
      }

      await platform.createNotificationChannel(fallbackChannel);

      FlutterUI.log.d("Configured fallback notification channel!");
    }
  }

  /// Disposes push handling
  static void dispose() {
    tappedNotificationPayloads?.dispose();
    tappedNotificationPayloads = null;

    messagesReceived?.dispose();
    messagesReceived = null;

    backgroundMessagesReceived?.dispose();
    backgroundMessagesReceived = null;
  }

  /// Only returns the custom data set by the server in the notification.
  static Map<String, dynamic>? getCustomData(Map<String?, Object?>? data) {
    if (data == null) {
      return null;
    }

    Map<String, dynamic> map = {};

    for (var entry in data.entries) {
      if (entry.key != null
          && entry.key != "aps") {
        map[entry.key!] = entry.value;
      }
    }

    return map;
  }

  static ServerConfig? prepareAppStart(Map<String, dynamic> data) {
    ServerConfig? serverConfig = ParseUtil.extractAppParameters(data);

    if (serverConfig != null) {
      if (IUiService().clientId.value == null) {
        IConfigService().getTemporaryStartupParameters().addAll(data);
      }

      return serverConfig;
    }
    else {
      return null;
    }
  }

  static void tryAppStartOrUpdateParameters(Map<String, dynamic> data) {
    //keep original key/value pairs as well
    Map<String, dynamic> dataStart = Map.of(data);

    //no app is running -> start app if possible
    if (IUiService().clientId.value == null) {

      ServerConfig? serverConfig = prepareAppStart(dataStart);

      //for push, the application must exist - we don't create apps by push notifications
      App? app = FlutterUI.searchAvailableApp(serverConfig);

      if (app != null) {
        IAppService().startApp(appId: app.id, autostart: true);
      }
    }
    else {
      //check if it's the same app and set parameters, otherwise start another app
      ServerConfig? serverConfig = ParseUtil.extractAppParameters(dataStart);

      //for push, the application must exist - we don't create apps by push notifications
      App? app = FlutterUI.searchAvailableApp(serverConfig);

      if (app != null) {
        if (IAppService().isCurrentApp(app)) {
          //send parameter to app
          unawaited(ICommandService().sendCommand(
            SetParameterCommand(
              parameter: dataStart,
              reason: "Received new push token",
            ),
            showDialogOnError: false,
          ));
        }
        else {
          IConfigService().getTemporaryStartupParameters().addAll(dataStart);

          IAppService().startApp(appId: app.id, autostart: true);
        }
      }
      else {
        if (data["appName"] == null && data.isNotEmpty) {
          //we have no app name... send parameters anyway
          unawaited(ICommandService().sendCommand(
            SetParameterCommand(
              parameter: dataStart,
              reason: "Received new push token",
            ),
            showDialogOnError: false,
          ));
        }
      }
    }
  }

  /// Handles local notification taps.
  static Future<void> handleLocalNotificationTap(NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;

    if (payload != null) {
      var data = jsonDecode(payload);
      tappedNotificationPayloads?.value += [data];

      if (data != null) {
        tryAppStartOrUpdateParameters(data);
      }
    }
  }

  /// Handles push notification taps.
  static Future<void> handleNotificationTap(Map<String?, Object?> data) async {
    tappedNotificationPayloads?.value += [data];

    Map<String, dynamic>? dataCustom = PushUtil.getCustomData(data);

    if (dataCustom?.isNotEmpty == true) {
      tryAppStartOrUpdateParameters(dataCustom!);
    }
  }

  /// Handles push notifications received while app is in foreground.
  static Future<void> handleOnMessage(RemoteMessage message) async {
    messagesReceived?.value += [message];

    var data = PushUtil.getCustomData(message.data);

    //We only show a notification - nothing else
    //If user taps, it will be handled
    if (data != null) {
      if (message.notification != null) {
        await localNotificationsPlugin.show(
          id: message.hashCode,
          title: message.notification!.title,
          body: message.notification!.body,
          notificationDetails: NotificationDetails(
            android: const AndroidNotificationDetails(
              // FCM channel
              "fcm_fallback_notification_channel",
              "Notifications",
              importance: Importance.max,
              priority: Priority.high
            ),
            iOS: DarwinNotificationDetails(
              subtitle: (message.data?["aps"] as Map?)?["alert"]?["subtitle"],
            ),
          ),
          payload: jsonEncode(data),
        );
        return;
      }
    }
  }

  /// Handles push notifications received while app is in background.
  static Future<void> handleOnBackgroundMessages(RemoteMessage message) async {
    backgroundMessagesReceived?.value += [message];

    //We do nothing here because notification has been shown and user has to tap
  }

  /// Gets the current push token if available
  static Future<String?> retrievePushToken() async {
    String? pushToken;
    try {
      // In case Push-Swift receives no token in time, it blocks until one arrives.
      pushToken = await Push.instance.token.timeout(const Duration(seconds: 1));

      //DON'T set currentToken = pushToken -> handleTokenUpdate will check changes
      //and requires registered services
    } catch (e, stack) {
      FlutterUI.log.e("Error retrieving push token", error: e, stackTrace: stack);
    }
    return pushToken;
  }

  /// Handles push token update.
  static FutureOr<void> handleTokenUpdate(String token) async {
    if (FlutterUI.log.cl(Lvl.d)) {
      FlutterUI.log.d("${currentToken != token ? 'New' : '(Existing)'} APNS/FCM registration token: $token");
    }

    if (currentToken != token) {
      currentToken = token;

      if (!IConfigService().offline.value && IUiService().clientId.value != null) {
        //send new token to server
        unawaited(ICommandService().sendCommand(
          SetParameterCommand(
            parameter: {AppParameterNames.pushToken: token},
            reason: "Received new push token",
          ),
          showDialogOnError: false,
        ));
      }
    }
  }

}
