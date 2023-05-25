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

import 'dart:convert';

import 'package:collection/collection.dart';

import '../../config/app_config.dart';
import '../../config/predefined_server_config.dart';
import '../../config/server_config.dart';
import '../../flutter_ui.dart';
import '../../mask/apps/app_overview_page.dart';
import '../../model/request/api_startup_request.dart';
import '../config/i_config_service.dart';
import 'app_service.dart';

class App {
  String? _id;

  late String? _name;
  late String? _baseUrl;
  late String? _username;
  late String? _password;
  late String? _title;
  late String? _icon;
  late String? _version;
  late Map<String, String>? _applicationStyle;

  static const String idSplitSequence = "@!@";
  static const String predefinedPrefix = "pr$idSplitSequence";

  static AppConfig? get _appConfig => IConfigService().getAppConfig();

  static PredefinedServerConfig? getPredefinedConfig(String? id) => id == null
      ? null
      : _appConfig?.serverConfigs!
          .firstWhereOrNull((e) => computeId(e.appName!, e.baseUrl!.toString(), predefined: true) == id);

  static String? computeId(String? name, String? url, {required bool predefined}) {
    if (name == null || url == null) {
      return null;
    }
    String sName = name.trim().replaceAll(RegExp(r"\W"), "_");
    String sUrl = url.trim().replaceAll("://", "_").replaceAll(RegExp(r"\W"), "_");
    String id = "$sName$idSplitSequence$sUrl";
    if (predefined) {
      id = predefinedPrefix + id;
    }
    return id;
  }

  static String? computeIdFromConfig(ServerConfig? config) {
    return computeId(config?.appName, config?.baseUrl?.toString(), predefined: false);
  }

  static isValidAppName(String name) {
    return !name.trim().startsWith(App.predefinedPrefix);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Helper
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  static bool _isPredefined(String id) => id.startsWith(predefinedPrefix);

  static bool get forceSingleAppMode => IConfigService().getAppConfig()!.forceSingleAppMode!;

  static bool get customAppsAllowed => IConfigService().getAppConfig()!.customAppsAllowed!;

  static bool get _isPredefinedLocked =>
      _isPredefinedHidden || IConfigService().getAppConfig()!.predefinedConfigsLocked!;

  static bool get _isPredefinedHidden => IConfigService().getAppConfig()!.predefinedConfigsParametersHidden!;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  static Future<App?> getApp(String id, {bool forceIfMissing = false}) async {
    if (_isPredefined(id)) {
      // Predefined
      if (forceIfMissing || getPredefinedConfig(id) != null) {
        var app = App._(id);
        await app.loadValues();
        return app;
      }
    } else {
      var appIds = AppService().storedAppIds.value;
      if (forceIfMissing || appIds.contains(id)) {
        var app = App._(id);
        await app.loadValues();
        return app;
      }
    }
    return null;
  }

  static Future<List<App>> getAppsByIDs(Iterable<String> ids) async {
    return (await Future.wait(ids.map((id) => App.getApp(id)).toList())).whereNotNull().toList();
  }

  static Future<App> createApp({required String name, required Uri baseUrl}) async {
    var app = App._(computeId(name, baseUrl.toString(), predefined: false)!);
    await app.loadValues();
    await app.updateName(name);
    await app.updateBaseUrl(baseUrl);
    await AppService().refreshStoredAppIds();
    return app;
  }

  static Future<App> createAppFromConfig(ServerConfig config) async {
    if (!config.isValid) throw ArgumentError("ServerConfig is not valid");
    var app = App._(computeIdFromConfig(config)!);
    await app.loadValues();
    await app.updateFromConfig(config);
    await AppService().refreshStoredAppIds();
    return app;
  }

  App._(String id) : _id = id;

  Future<void> loadValues() async {
    _name = await _getString("name");
    _baseUrl = await _getString("baseUrl");
    _username = await _getString("username");
    _password = await _getString("password");
    _title = await _getString("title");
    _icon = await _getString("icon");
    _version = await _getString("version");
    String? styleJson = await _getString("applicationStyle");
    _applicationStyle = (styleJson != null ? Map<String, String>.from(jsonDecode(styleJson)) : null);
  }

  String get id {
    _checkId();
    return _id!;
  }

  Future<void> updateFromConfig(ServerConfig config) async {
    await updateName(config.appName);
    await updateBaseUrl(config.baseUrl);
    await updateTitle(config.title);
    await updateIcon(config.icon);
    await updateUsername(config.username);
    await updatePassword(config.password);
    await updateDefault(config.isDefault);
  }

  /// {@template app.name}
  /// The application name defined by the server.
  ///
  /// Used to identify this app on the server.
  /// {@endtemplate}
  String? get name => _name ?? getPredefinedConfig(_id)?.appName;

  /// Sets the name of this app.
  Future<void> updateName(String? name) {
    assert(!locked);
    String? fallback = getPredefinedConfig(_id)?.appName;
    var value = name == fallback ? null : name?.toString();
    return _setString("name", value).then((_) => _name = value);
  }

  /// {@template app.url}
  /// The url of this app.
  ///
  /// Used to connect to the server.
  /// {@endtemplate}
  Uri? get baseUrl {
    String? sBaseUrl = _baseUrl;
    return (sBaseUrl != null ? Uri.parse(sBaseUrl) : null) ?? getPredefinedConfig(_id)?.baseUrl;
  }

  /// Sets the base-url of this app.
  Future<void> updateBaseUrl(Uri? url) {
    assert(!locked);
    Uri? fallback = getPredefinedConfig(_id)?.baseUrl;
    var value = url == fallback ? null : url?.toString();
    return _setString("baseUrl", value).then((_) => _baseUrl = value);
  }

  /// {@template app.username}
  /// The optional username of this app.
  ///
  /// Used to auto-login in the app server.
  /// {@endtemplate}
  String? get username => _username ?? getPredefinedConfig(_id)?.username;

  /// Sets the username of this app.
  Future<void> updateUsername(String? username) {
    String? fallback = getPredefinedConfig(_id)?.username;
    var value = username == fallback ? null : username?.toString();
    return _setString("username", value).then((_) => _username = value);
  }

  /// {@template app.password}
  /// The optional password of this app.
  ///
  /// Used to auto-login in the app server.
  /// {@endtemplate}
  String? get password => _password ?? getPredefinedConfig(_id)?.password;

  /// Sets the name of this app.
  Future<void> updatePassword(String? password) {
    String? fallback = getPredefinedConfig(_id)?.password;
    var value = password == fallback ? null : password?.toString();
    return _setString("password", value).then((_) => _password = value);
  }

  /// {@template app.title}
  /// The title of this app.
  ///
  /// Shown in the [AppOverviewPage].
  /// {@endtemplate}
  String? get title => _title ?? getPredefinedConfig(_id)?.title;

  /// Sets the name of this app.
  Future<void> updateTitle(String? title) {
    assert(!locked);
    String? fallback = getPredefinedConfig(_id)?.title;
    var value = title == fallback ? null : title?.toString();
    return _setString("title", value).then((_) => _title = value);
  }

  /// {@template app.icon}
  /// The icon of this app.
  ///
  /// This can either be a full url or a JVx resource path.
  ///
  /// Shown in the [AppOverviewPage].
  /// {@endtemplate}
  String? get icon => _icon ?? getPredefinedConfig(_id)?.icon;

  /// Sets the name of this app.
  Future<void> updateIcon(String? icon) {
    assert(!locked);
    String? fallback = getPredefinedConfig(_id)?.icon;
    var value = icon == fallback ? null : icon?.toString();
    return _setString("icon", value).then((_) => _icon = value);
  }

  /// {@template app.default}
  /// Whether this app should be viewed as the default app.
  ///
  /// Shown in the [AppOverviewPage].
  /// {@endtemplate}
  bool get isDefault {
    return IConfigService().defaultApp.value == _id;
  }

  /// Sets the default state of this app.
  Future<void> updateDefault(bool? isDefault) async {
    assert(!locked);
    if (isDefault ?? false) {
      await IConfigService().updateDefaultApp(_id);
    } else {
      if (this.isDefault) {
        await IConfigService().updateDefaultApp(null);
      }
    }
  }

  /// {@template app.locked}
  /// Whether this app is editable in the app overview.
  ///
  /// Is implicitly overridden by [parametersHidden].
  /// {@endtemplate}
  ///
  /// This is determined by whether this is a predefined app and this
  /// or all predefined apps are locked, or if it isn't a predefined app
  /// and customs aren't allowed.
  bool get locked =>
      (predefined &&
          (_isPredefinedLocked ||
              (getPredefinedConfig(_id) != null &&
                  ((getPredefinedConfig(_id)!.locked ?? true) ||
                      (getPredefinedConfig(_id)!.parametersHidden ?? false))))) ||
      (!predefined && !customAppsAllowed && !forceSingleAppMode);

  /// {@template app.parametersHidden}
  /// Whether parameters such as [name] or
  /// [baseUrl] are shown to the user.
  ///
  /// Implicitly overrides [locked] to true.
  /// {@endtemplate}
  ///
  /// This is determined by whether this is a predefined app and this
  /// or all predefined apps are hidden.
  bool get parametersHidden =>
      predefined && (_isPredefinedHidden || (getPredefinedConfig(_id)?.parametersHidden ?? false));

  /// {@template app.version}
  /// The current version of this app, if known.
  /// {@endtemplate}
  String? get version => _version;

  /// {@template app.applicationStyle}
  /// The style settings of this app, if saved.
  /// {@endtemplate}
  Map<String, String>? get applicationStyle => _applicationStyle;

  /// Retrieves a bool value by its key in connection to the app id.
  ///
  /// If [_id] is null or [usesUserParameter] is false, this returns null.
  ///
  /// {@macro app.key}
  // ignore: unused_element
  Future<bool?> _getBool(String key) async {
    return !usesUserParameter
        ? null
        : (_id != null ? IConfigService().getConfigHandler().getPreference("$_id.$key") : null);
  }

  /// Retrieves a string value by its key in connection to the app id.
  ///
  /// If [_id] is null or [usesUserParameter] is false, this returns null.
  ///
  /// {@macro app.key}
  Future<String?> _getString(String key) async {
    return !usesUserParameter
        ? null
        : (_id != null ? IConfigService().getConfigHandler().getPreference("$_id.$key") : null);
  }

  /// Persists a string value by its key in connection to the app id.
  ///
  /// {@template app.key}
  /// The key is structured as following:
  /// ```dart
  /// "$appId.$key"
  /// ```
  /// {@endtemplate}
  ///
  /// `null` removes the value from the storage.
  Future<bool> _setString(String key, String? value) async {
    _checkId();
    String prefix = _id!;
    return IConfigService().getConfigHandler().setPreference("$prefix.$key", value);
  }

  void _checkId() {
    if (_id == null) {
      throw StateError("Cannot access an already disposed app.\n"
          "This app has already been removed, further calls to this object are invalid.");
    }
  }

  /// Whether it is allowed to use the user-modified parameters in case this is a predefined app.
  ///
  /// If this is not a predefined app ([predefined] == false) this always returns true.
  bool get usesUserParameter =>
      !predefined ||
      (predefined &&
          !(_appConfig!.predefinedConfigsParametersHidden! || _appConfig!.predefinedConfigsLocked!) &&
          !locked &&
          !parametersHidden);

  bool get predefined {
    return _id == null ? false : _isPredefined(_id!);
  }

  /// Whether this config contains enough information to send a [ApiStartupRequest].
  bool get isStartable => (name?.isNotEmpty ?? false) && baseUrl != null;

  String? get effectiveTitle => title ?? applicationStyle?["login.title"] ?? name;

  /// Updates the id of the this app.
  ///
  /// **Attention:** Check if this is really necessary before using that method!
  Future<void> updateId(String newAppId) async {
    _checkId();
    assert(!predefined && !locked, "Can't update ID of predefined app.");

    String oldAppId = _id!;

    await IConfigService().getConfigHandler().updateAppKey(oldAppId, newAppId);

    String? currentApp = IConfigService().currentApp.value;
    if (currentApp == oldAppId) {
      await IConfigService().updateCurrentApp(newAppId);
    }
    String? lastApp = IConfigService().lastApp.value;
    if (lastApp == oldAppId) {
      await IConfigService().updateLastApp(newAppId);
    }
    String? defaultApp = IConfigService().defaultApp.value;
    if (defaultApp == oldAppId) {
      await IConfigService().updateDefaultApp(newAppId);
    }

    await IConfigService().getFileManager().renameIndependentDirectory(
        [oldAppId], id).catchError((e, stack) => FlutterUI.log.w("Failed to move app directory ($id)", e, stack));

    await AppService().refreshStoredAppIds();

    _id = newAppId;
  }

  /// Deletes this app.
  ///
  /// In case this is a predefined app, removes every persisted data from the storage.
  ///
  /// If this was a custom app the object becomes unusable after this action and may be discarded.
  Future<void> delete() async {
    _checkId();

    String appId = _id!;
    if (!predefined) {
      // Disables this object.
      _id = null;
    }

    await IConfigService().getConfigHandler().removeAppKey(appId);

    if (IConfigService().defaultApp.value == appId) {
      await IConfigService().updateDefaultApp(null);
    }
    if (IConfigService().lastApp.value == appId) {
      await IConfigService().updateLastApp(null);
    }

    await IConfigService().getFileManager().deleteIndependentDirectory([appId],
        recursive: true).catchError((e, stack) => FlutterUI.log.w("Failed to delete app directory ($appId)", e, stack));

    await AppService().refreshStoredAppIds();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is App && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
