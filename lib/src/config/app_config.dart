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

import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/config/application_parameters.dart';
import '../service/apps/app.dart';
import 'log/log_config.dart';
import 'offline_config.dart';
import 'predefined_server_config.dart';
import 'ui_config.dart';
import 'version_config.dart';

class AppConfig {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// A one-line description used by the device to identify the app for the user.
  ///
  /// In the web, this can be overridden by specifying a title in [ApplicationParameters.applicationTitleWeb].
  /// If both are null, the appName from pubspec.yaml is used.
  ///
  /// See also:
  /// * [WidgetsApp.title]
  /// * [ApplicationParameters.applicationTitleWeb]
  /// * [PackageInfo.appName]
  final String? title;

  /// A link that will be launched by a tile button in the settings page.
  ///
  /// See also:
  /// * [launchUrl]
  final Uri? privacyPolicy;

  /// The timeout used by the HTTP Client for the initial connection and the WebSocket.
  final Duration? connectTimeout;

  /// The timeout used by the HTTP Client for the read and write operations.
  ///
  /// Defaults to the same value as [connectTimeout].
  final Duration? requestTimeout;

  /// The interval at which an "Alive" request is sent while no other requests are sent.
  final Duration? aliveInterval;

  /// The interval at which the websocket will initiate a PING message and wait for a PONG response.
  final Duration? wsPingInterval;

  /// Whether the app auto restarts as soon as an expired session is encountered.
  ///
  /// Otherwise a dialog with a cancel button is shown.
  final bool? autoRestartOnSessionExpired;

  /// Whether the app overview should be shown when there is a single app which is not marked as default.
  final bool? showAppOverviewWithoutDefault;

  /// Whether custom apps are allowed.
  ///
  /// This affects:
  /// * Add App
  /// * Edit App
  /// * Single App mode
  final bool? customAppsAllowed;

  /// Whether the single app mode is forced.
  ///
  /// This affects:
  /// * Single app mode
  final bool? forceSingleAppMode;

  /// Whether the predefined apps in the app overview
  /// are editable by the user.
  ///
  /// Is implicitly overridden by [predefinedConfigsParametersHidden].
  ///
  /// This affects:
  /// * Edit App
  /// * Reset App
  ///
  /// See also:
  /// * [App.locked]
  final bool? predefinedConfigsLocked;

  /// Whether parameters such as [App.name] or [App.baseUrl]
  /// of predefined apps are shown to the user.
  ///
  /// Sets [predefinedConfigsLocked] implicitly to true.
  ///
  /// This affects:
  /// * Edit App Dialog
  /// * App Details in settings
  ///
  /// See also:
  /// * [App.parametersHidden]
  final bool? predefinedConfigsParametersHidden;

  final LogConfig? logConfig;
  final UiConfig? uiConfig;
  final List<PredefinedServerConfig>? serverConfigs;
  final VersionConfig? versionConfig;
  final OfflineConfig? offlineConfig;

  final Map<String, dynamic>? applicationParameters;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const AppConfig({
    this.title,
    this.privacyPolicy,
    this.requestTimeout,
    this.connectTimeout,
    this.aliveInterval,
    this.wsPingInterval,
    this.autoRestartOnSessionExpired,
    this.showAppOverviewWithoutDefault,
    this.customAppsAllowed,
    this.forceSingleAppMode,
    this.predefinedConfigsLocked,
    this.predefinedConfigsParametersHidden,
    this.logConfig,
    this.uiConfig,
    this.serverConfigs,
    this.versionConfig,
    this.offlineConfig,
    this.applicationParameters,
  });

  const AppConfig.defaults()
      : this(
          title: "JVx Mobile",
          connectTimeout: const Duration(seconds: 10),
          aliveInterval: const Duration(seconds: 30),
          wsPingInterval: const Duration(seconds: 10),
          autoRestartOnSessionExpired: true,
          showAppOverviewWithoutDefault: false,
          customAppsAllowed: true,
          forceSingleAppMode: false,
          predefinedConfigsLocked: true,
          predefinedConfigsParametersHidden: true,
          logConfig: const LogConfig.defaults(),
          uiConfig: const UiConfig.defaults(),
          serverConfigs: const [],
          versionConfig: const VersionConfig.defaults(),
          offlineConfig: const OfflineConfig.defaults(),
        );

  AppConfig.fromJson(Map<String, dynamic> json)
      : this(
          title: json['title'],
          privacyPolicy: json['privacyPolicy'] != null ? Uri.tryParse(json['privacyPolicy']) : null,
          connectTimeout: json['connectTimeout'] != null ? Duration(milliseconds: json['connectTimeout']) : null,
          requestTimeout: json['requestTimeout'] != null ? Duration(milliseconds: json['requestTimeout']) : null,
          aliveInterval: json['aliveInterval'] != null ? Duration(milliseconds: json['aliveInterval']) : null,
          wsPingInterval: json['wsPingInterval'] != null ? Duration(milliseconds: json['wsPingInterval']) : null,
          autoRestartOnSessionExpired: json['autoRestartOnSessionExpired'],
          showAppOverviewWithoutDefault: json['showAppOverviewWithoutDefault'],
          customAppsAllowed: json['customAppsAllowed'],
          forceSingleAppMode: json['forceSingleAppMode'],
          predefinedConfigsLocked: json['serverConfigsLocked'],
          predefinedConfigsParametersHidden: json['serverConfigsParametersHidden'],
          logConfig: json['logConfig'] != null ? LogConfig.fromJson(json['logConfig']) : null,
          uiConfig: json['uiConfig'] != null ? UiConfig.fromJson(json['uiConfig']) : null,
          serverConfigs:
              (json['serverConfigs'] as List<dynamic>?)?.map((e) => PredefinedServerConfig.fromJson(e)).toList(),
          versionConfig: json['versionConfig'] != null ? VersionConfig.fromJson(json['versionConfig']) : null,
          offlineConfig: json['offlineConfig'] != null ? OfflineConfig.fromJson(json['offlineConfig']) : null,
          applicationParameters: json['applicationParameters'],
        );

  AppConfig merge(AppConfig? other) {
    if (other == null) return this;

    return AppConfig(
      title: other.title ?? title,
      privacyPolicy: other.privacyPolicy ?? privacyPolicy,
      connectTimeout: other.connectTimeout ?? connectTimeout,
      requestTimeout: other.requestTimeout ?? requestTimeout,
      aliveInterval: other.aliveInterval ?? aliveInterval,
      wsPingInterval: other.wsPingInterval ?? wsPingInterval,
      autoRestartOnSessionExpired: other.autoRestartOnSessionExpired ?? autoRestartOnSessionExpired,
      showAppOverviewWithoutDefault: other.showAppOverviewWithoutDefault ?? showAppOverviewWithoutDefault,
      customAppsAllowed: other.customAppsAllowed ?? customAppsAllowed,
      forceSingleAppMode: other.forceSingleAppMode ?? forceSingleAppMode,
      predefinedConfigsLocked: other.predefinedConfigsLocked ?? predefinedConfigsLocked,
      predefinedConfigsParametersHidden: other.predefinedConfigsParametersHidden ?? predefinedConfigsParametersHidden,
      logConfig: logConfig?.merge(other.logConfig) ?? other.logConfig,
      uiConfig: uiConfig?.merge(other.uiConfig) ?? other.uiConfig,
      serverConfigs: other.serverConfigs ?? serverConfigs,
      versionConfig: versionConfig?.merge(other.versionConfig) ?? other.versionConfig,
      offlineConfig: offlineConfig?.merge(other.offlineConfig) ?? other.offlineConfig,
      applicationParameters: (applicationParameters ?? {})..addAll(other.applicationParameters ?? {}),
    );
  }
}
