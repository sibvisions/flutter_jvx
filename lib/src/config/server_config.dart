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

import '../mask/apps/app_overview_page.dart';
import '../model/request/api_startup_request.dart';
import '../service/config/config_controller.dart';
import '../util/parse_util.dart';

class ServerConfig {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final String? appName;
  final Uri? baseUrl;
  final String? username;
  final String? password;

  /// The title of this config.
  ///
  /// Shown in the [AppOverviewPage].
  final String? title;

  /// The icon of this config.
  ///
  /// This can either be a full url or a JVx resource path.
  ///
  /// Shown in the [AppOverviewPage].
  final String? icon;

  /// Whether this config should be viewed as the default config.
  ///
  /// Shown in the [AppOverviewPage].
  final bool? isDefault;

  /// {@macro app.locked}
  final bool? locked;

  /// {@macro app.parametersHidden}
  final bool? parametersHidden;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const ServerConfig({
    this.appName,
    this.baseUrl,
    this.username,
    this.password,
    this.title,
    this.icon,
    this.isDefault,
    this.locked,
    this.parametersHidden,
  });

  const ServerConfig.empty() : this();

  ServerConfig.fromJson(Map<String, dynamic> json)
      : this(
          appName: ParseUtil.ensureNullOnEmpty(json['appName']),
          baseUrl: json['baseUrl'] != null ? Uri.parse(json['baseUrl']) : null,
          username: ParseUtil.ensureNullOnEmpty(json['username']),
          password: ParseUtil.ensureNullOnEmpty(json['password']),
          title: ParseUtil.ensureNullOnEmpty(json['title']),
          icon: ParseUtil.ensureNullOnEmpty(json['icon']),
          isDefault: json['default'],
          locked: json['locked'],
          parametersHidden: json['parametersHidden'],
        );

  /// Whether this config contains enough information to send a [ApiStartUpRequest].
  bool get isStartable => (appName?.isNotEmpty ?? false) && baseUrl != null;

  String? get effectiveTitle => title ?? ConfigController().getAppStyle(appName)?["login.title"] ?? appName;

  /// Returns a new [ServerConfig] which contains the merged fields of [this] and [other].
  ServerConfig merge(ServerConfig? other) {
    if (other == null) return this;

    return ServerConfig(
      appName: other.appName ?? appName,
      baseUrl: other.baseUrl ?? baseUrl,
      username: other.username ?? username,
      password: other.password ?? password,
      title: other.title ?? title,
      icon: other.icon ?? icon,
      isDefault: other.isDefault ?? isDefault,
      locked: other.locked ?? locked,
      parametersHidden: other.parametersHidden ?? parametersHidden,
    );
  }

  /// Returns a new [ServerConfig] which only contains the differences between [this] and [other].
  ServerConfig diff(ServerConfig? other) {
    if (other == null) return this;
    if (other == this) return const ServerConfig.empty();

    return ServerConfig(
      appName: other.appName != appName ? appName : null,
      baseUrl: other.baseUrl != baseUrl ? baseUrl : null,
      username: other.username != username ? username : null,
      password: other.password != password ? password : null,
      title: other.title != title ? title : null,
      icon: other.icon != icon ? icon : null,
      isDefault: (other.isDefault ?? false) != (isDefault ?? false) ? isDefault : null,
      locked: (other.locked ?? false) != (locked ?? false) ? locked : null,
      parametersHidden: (other.parametersHidden ?? false) != (parametersHidden ?? false) ? parametersHidden : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'appName': appName,
        'baseUrl': baseUrl,
        'username': username,
        'password': password,
        'title': title,
        'icon': icon,
        'default': isDefault,
        'locked': locked,
        'parametersHidden': parametersHidden,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServerConfig &&
          runtimeType == other.runtimeType &&
          appName == other.appName &&
          baseUrl == other.baseUrl &&
          username == other.username &&
          password == other.password &&
          title == other.title &&
          icon == other.icon &&
          isDefault == other.isDefault &&
          locked == other.locked &&
          parametersHidden == other.parametersHidden;

  @override
  int get hashCode =>
      appName.hashCode ^
      baseUrl.hashCode ^
      username.hashCode ^
      password.hashCode ^
      title.hashCode ^
      icon.hashCode ^
      isDefault.hashCode ^
      locked.hashCode ^
      parametersHidden.hashCode;
}
