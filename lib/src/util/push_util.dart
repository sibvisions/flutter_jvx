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
import '../service/apps/i_app_service.dart';
import '../service/command/i_command_service.dart';
import '../service/config/i_config_service.dart';
import '../service/ui/i_ui_service.dart';
import 'parse_util.dart';

abstract class PushUtil {
  static FlutterLocalNotificationsPlugin localNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static Map<String?, Object?>? notificationWhichLaunchedApp;

  static ServerConfig? handleNotificationData(Map<String?, Object?>? data) {
    if (data != null) {
      var notificationConfig = ParseUtil.extractAppParameters(Map.from(data));

      if (notificationConfig != null) {
        data.entries
            .where((element) => element.key != null)
            .forEach((entry) => IConfigService().updateCustomStartupProperties(entry.key!, entry.value));
        return notificationConfig;
      }
    }
    return null;
  }

  /// Only returns the custom data set by the server in the notification.
  static T extractJVxData<T extends Map<K, V>?, K extends String?, V extends Object?>(T data) {
    if (data == null) return data;
    Map<K, V> map = Map<K, V>.from(data);
    map.remove("aps");
    return map as T;
  }

  static Future<void> sendPushData(Map<String, Object?> data) async {
    if (!IConfigService().offline.value && IUiService().clientId.value != null) {
      await ICommandService()
          .sendCommand(SetParameterCommand(
        parameter: data,
        reason: "Received new push data",
      ))
          .onError((error, stackTrace) {
        FlutterUI.log.w("Failed to send push data to server", error: error, stackTrace: stackTrace);
      });
    }
  }

  /// Handles local notification taps.
  static Future<void> handleLocalNotificationTap(
    ValueNotifier<List<Map<String?, Object?>>> notifier,
    NotificationResponse notificationResponse,
  ) async {
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      var data = jsonDecode(payload);
      notifier.value += [data];

      var notificationConfig = PushUtil.handleNotificationData(data);
      if (notificationConfig != null) {
        unawaited(IAppService().startCustomApp(notificationConfig, force: true));
      } else {
        await PushUtil.sendPushData({"pushData": data});
      }
    }
  }

  /// Handles push notification taps.
  static Future<void> handleNotificationTap(
    ValueNotifier<List<Map<String?, Object?>>> notifier,
    Map<String?, Object?> data,
  ) async {
    notifier.value += [data];

    data = PushUtil.extractJVxData(data);

    var notificationConfig = PushUtil.handleNotificationData(data);
    if (notificationConfig != null) {
      unawaited(IAppService().startCustomApp(notificationConfig, force: true));
    } else {
      await PushUtil.sendPushData({"pushData": data});
    }
  }

  /// Handles push notifications received while app is in foreground.
  static Future<void> handleOnMessage(
    ValueNotifier<List<RemoteMessage>> messagesReceived,
    RemoteMessage message,
  ) async {
    messagesReceived.value += [message];

    var data = PushUtil.extractJVxData(message.data);
    if (data != null) {
      if (message.notification != null) {
        await localNotificationsPlugin.show(
          message.hashCode,
          message.notification!.title,
          message.notification!.body,
          NotificationDetails(
            android: const AndroidNotificationDetails(
              // FCM channel
              "fcm_fallback_notification_channel",
              "Misc",
            ),
            iOS: DarwinNotificationDetails(
              subtitle: (message.data?["aps"] as Map?)?["alert"]?["subtitle"],
            ),
          ),
          payload: jsonEncode(data),
        );
        return;
      }

      await PushUtil.sendPushData({"pushData": data});
    }
  }

  /// Handles push notifications received while app is in background.
  static Future<void> handleOnBackgroundMessages(
    ValueNotifier<List<RemoteMessage>> notifier,
    RemoteMessage message,
  ) async {
    notifier.value += [message];

    await PushUtil.sendPushData({
      "pushData": PushUtil.extractJVxData<Map<String?, Object?>?, String?, Object?>(message.data),
    });
  }

  /// Handles device token updates.
  static Future<void> handleTokenUpdates(String token) async {
    FlutterUI.log.d("New APNS/FCM registration token: $token");
    await PushUtil.sendPushData({"pushToken": token});
  }
}
