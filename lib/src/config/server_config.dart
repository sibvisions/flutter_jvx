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
import 'qr_config.dart';

/// This is a config for a JVx app, that can be either provided
/// via the [QRConfig] or the browser URL.
///
/// Used to show apps in [AppOverviewPage].
class ServerConfig {
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
        );

  ServerConfig.fromQR(Map<String, dynamic> json)
      : this(
          appName: ParseUtil.ensureNullOnEmpty(
              (json[QRConfig.APP_NAME] ?? json[QRConfig.APPLICATION] ?? json[QRConfig.APPLIKATION])?.trim()),
          baseUrl: json[QRConfig.URL] != null ? Uri.parse(json[QRConfig.URL]?.trim()) : null,
          username: ParseUtil.ensureNullOnEmpty(json[QRConfig.USER]?.trim()),
          password: ParseUtil.ensureNullOnEmpty(json[QRConfig.PASSWORD]?.trim()),
          title: ParseUtil.ensureNullOnEmpty(json[QRConfig.TITLE]?.trim()),
          icon: ParseUtil.ensureNullOnEmpty(json[QRConfig.ICON]?.trim()),
          isDefault: json[QRConfig.IS_DEFAULT],
        );

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
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overrides
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
              isDefault == other.isDefault;

  @override
  int get hashCode =>
      appName.hashCode ^
      baseUrl.hashCode ^
      username.hashCode ^
      password.hashCode ^
      title.hashCode ^
      icon.hashCode ^
      isDefault.hashCode;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Whether this config contains enough information to be valid.
  bool get isValid => (appName?.isNotEmpty ?? false) && baseUrl != null;

  Map<String, dynamic> toJson() => {
        'appName': appName,
        'baseUrl': baseUrl,
        'username': username,
        'password': password,
        'title': title,
        'icon': icon,
        'default': isDefault,
      };

  Map<String, dynamic> toQR() => {
        QRConfig.APP_NAME: appName,
        QRConfig.URL: baseUrl?.toString(),
        if (title != null) QRConfig.TITLE: title,
        if (icon != null) QRConfig.ICON: icon,
        if (isDefault != null) QRConfig.IS_DEFAULT: isDefault,
      };

}
