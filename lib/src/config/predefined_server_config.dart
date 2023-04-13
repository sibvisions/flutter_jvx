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
import '../util/parse_util.dart';
import 'app_config.dart';

/// This is a config for a JVx app, that is provided
/// via the [AppConfig.serverConfigs].
///
/// Used to show apps in [AppOverviewPage].
class PredefinedServerConfig {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// {@macro app.name}
  final String? appName;

  /// {@macro app.url}
  final Uri? baseUrl;

  /// {@macro app.username}
  final String? username;

  /// {@macro app.password}
  final String? password;

  /// {@macro app.title}
  final String? title;

  /// {@macro app.icon}
  final String? icon;

  /// {@macro app.default}
  final bool? isDefault;

  /// {@macro app.locked}
  final bool? locked;

  /// {@macro app.parametersHidden}
  final bool? parametersHidden;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const PredefinedServerConfig({
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

  const PredefinedServerConfig.empty() : this();

  PredefinedServerConfig.fromJson(Map<String, dynamic> json)
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

  /// Whether this config contains enough information to be valid.
  bool get isValid => (appName?.isNotEmpty ?? false) && baseUrl != null;

  /// Returns a new [PredefinedServerConfig] which contains the merged fields of [this] and [other].
  PredefinedServerConfig merge(PredefinedServerConfig? other) {
    if (other == null) return this;

    return PredefinedServerConfig(
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

  /// Returns a new [PredefinedServerConfig] which only contains the differences between [this] and [other].
  PredefinedServerConfig diff(PredefinedServerConfig? other) {
    if (other == null) return this;
    if (other == this) return const PredefinedServerConfig.empty();

    return PredefinedServerConfig(
      appName: other.appName != appName ? appName : null,
      baseUrl: other.baseUrl != baseUrl ? baseUrl : null,
      username: other.username != username ? username : null,
      password: other.password != password ? password : null,
      title: other.title != title ? title : null,
      icon: other.icon != icon ? icon : null,
      isDefault: (other.isDefault ?? false) != (isDefault ?? false) ? isDefault : null,
      locked: (other.locked ?? true) != (locked ?? true) ? locked : null,
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
      other is PredefinedServerConfig &&
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
