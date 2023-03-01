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

import 'offline_config.dart';
import 'server_config.dart';
import 'ui_config.dart';
import 'version_config.dart';

class AppConfig {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final String? title;
  final Uri? privacyPolicy;
  final Duration? requestTimeout;
  final Duration? aliveInterval;
  final Duration? wsPingInterval;
  final bool? autoRestartOnSessionExpired;

  /// Whether the app overview should be shown when there is a single app which is not marked as default.
  final bool? showAppOverviewWithoutDefault;

  /// {@template app.locked}
  /// Whether the apps in the app overview can be modified.
  ///
  /// This controls:
  /// * Add App
  /// * Edit App
  /// * Remove App
  /// {@endtemplate}
  ///
  /// This applies to all configs.
  final bool? configsLocked;

  /// {@template app.hidden}
  /// Whether app details such as [ServerConfig.appName] or
  /// [ServerConfig.baseUrl] can be seen by the user.
  ///
  /// This controls:
  /// * App Details in settings
  /// * Edit App View
  /// {@endtemplate}
  ///
  /// This applies to all configs.
  final bool? configsHidden;

  final UiConfig? uiConfig;
  final List<ServerConfig>? serverConfigs;
  final VersionConfig? versionConfig;
  final OfflineConfig? offlineConfig;

  final Map<String, dynamic>? startupParameters;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const AppConfig({
    this.title,
    this.privacyPolicy,
    this.requestTimeout,
    this.aliveInterval,
    this.wsPingInterval,
    this.autoRestartOnSessionExpired,
    this.showAppOverviewWithoutDefault,
    this.configsLocked,
    this.configsHidden,
    this.uiConfig,
    this.serverConfigs,
    this.versionConfig,
    this.offlineConfig,
    this.startupParameters,
  });

  const AppConfig.empty()
      : this(
          title: "JVx Mobile",
          requestTimeout: const Duration(seconds: 10),
          aliveInterval: const Duration(seconds: 30),
          wsPingInterval: const Duration(seconds: 10),
          autoRestartOnSessionExpired: true,
          showAppOverviewWithoutDefault: false,
          configsLocked: false,
          configsHidden: false,
          uiConfig: const UiConfig.empty(),
          serverConfigs: const [],
          versionConfig: const VersionConfig.empty(),
          offlineConfig: const OfflineConfig.empty(),
        );

  AppConfig.fromJson(Map<String, dynamic> json)
      : this(
          title: json['title'],
          privacyPolicy: json['privacyPolicy'] != null ? Uri.tryParse(json['privacyPolicy']) : null,
          requestTimeout: json['requestTimeout'] != null ? Duration(milliseconds: json['requestTimeout']) : null,
          aliveInterval: json['aliveInterval'] != null ? Duration(milliseconds: json['aliveInterval']) : null,
          wsPingInterval: json['wsPingInterval'] != null ? Duration(milliseconds: json['wsPingInterval']) : null,
          autoRestartOnSessionExpired: json['autoRestartOnSessionExpired'],
          showAppOverviewWithoutDefault: json['showAppOverviewWithoutDefault'],
          configsLocked: json['configsLocked'],
          configsHidden: json['configsHidden'],
          uiConfig: json['uiConfig'] != null ? UiConfig.fromJson(json['uiConfig']) : null,
          serverConfigs: (json['serverConfigs'] as List<dynamic>?)?.map((e) => ServerConfig.fromJson(e)).toList(),
          versionConfig: json['versionConfig'] != null ? VersionConfig.fromJson(json['versionConfig']) : null,
          offlineConfig: json['offlineConfig'] != null ? OfflineConfig.fromJson(json['offlineConfig']) : null,
          startupParameters: json['startupParameters'],
        );

  AppConfig merge(AppConfig? other) {
    if (other == null) return this;

    return AppConfig(
      title: other.title ?? title,
      privacyPolicy: other.privacyPolicy ?? privacyPolicy,
      requestTimeout: other.requestTimeout ?? requestTimeout,
      aliveInterval: other.aliveInterval ?? aliveInterval,
      wsPingInterval: other.wsPingInterval ?? wsPingInterval,
      autoRestartOnSessionExpired: other.autoRestartOnSessionExpired ?? autoRestartOnSessionExpired,
      showAppOverviewWithoutDefault: other.showAppOverviewWithoutDefault ?? showAppOverviewWithoutDefault,
      configsLocked: other.configsLocked ?? configsLocked,
      configsHidden: other.configsHidden ?? configsHidden,
      uiConfig: uiConfig?.merge(other.uiConfig) ?? other.uiConfig,
      serverConfigs: other.serverConfigs ?? serverConfigs,
      versionConfig: versionConfig?.merge(other.versionConfig) ?? other.versionConfig,
      offlineConfig: offlineConfig?.merge(other.offlineConfig) ?? other.offlineConfig,
      startupParameters: (startupParameters ?? {})..addAll(other.startupParameters ?? {}),
    );
  }
}
