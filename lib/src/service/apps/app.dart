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
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_config.dart';
import '../../config/predefined_server_config.dart';
import '../../config/server_config.dart';
import '../../flutter_ui.dart';
import '../../mask/apps/app_overview_page.dart';
import '../../model/request/api_startup_request.dart';
import '../config/config_controller.dart';
import 'app_service.dart';

class App {
  String? _id;

  static const String idSplitSequence = "@!@";
  static const String predefinedPrefix = "pr$idSplitSequence";

  static SharedPreferences get _sharedPrefs => ConfigController().getConfigService().getSharedPreferences();

  static AppConfig? get _appConfig => ConfigController().getAppConfig();

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

  static bool get customAppsAllowed => ConfigController().getAppConfig()!.customAppsAllowed!;

  static bool get _isPredefinedLocked =>
      _isPredefinedHidden || ConfigController().getAppConfig()!.predefinedConfigsLocked!;

  static bool get _isPredefinedHidden => ConfigController().getAppConfig()!.predefinedConfigsParametersHidden!;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  static App? getApp(String id, {bool forceIfMissing = false}) {
    if (_isPredefined(id)) {
      // Predefined
      if (forceIfMissing || getPredefinedConfig(id) != null) {
        return App._(id);
      }
    } else {
      var appIds = AppService().getStoredAppIds();
      if (forceIfMissing || appIds.contains(id)) {
        return App._(id);
      }
    }
    return null;
  }

  static List<App> getAppsByIDs(Iterable<String> ids) {
    return ids
        .map((id) => App.getApp(id))
        .whereNotNull()
        .sortedBy<String>((app) => (app.effectiveTitle ?? "").toLowerCase());
  }

  static App createApp({required String name, required Uri baseUrl}) {
    var app = App._(computeId(name, baseUrl.toString(), predefined: false)!);
    app.updateName(name);
    app.updateBaseUrl(baseUrl);
    return app;
  }

  static Future<App> createAppFromConfig(ServerConfig config) async {
    if (!config.isValid) throw ArgumentError("ServerConfig is not valid");
    var app = App._(computeIdFromConfig(config)!);
    await app.updateFromConfig(config);
    return app;
  }

  App._(String id) : _id = id;

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
  /// The name of this app.
  ///
  /// Used to identify the app on the server.
  /// {@endtemplate}
  String? get name => _getString("name") ?? getPredefinedConfig(_id)?.appName;

  /// Sets the name of this app.
  Future<void> updateName(String? name) {
    assert(!locked);
    String? fallback = getPredefinedConfig(_id)?.appName;
    return _setString(
      "name",
      name == fallback ? null : name?.toString(),
    );
  }

  /// {@template app.url}
  /// The url of this app.
  ///
  /// Used to connect to the app server.
  /// {@endtemplate}
  Uri? get baseUrl {
    String? sBaseUrl = _getString("baseUrl");
    return (sBaseUrl != null ? Uri.parse(sBaseUrl) : null) ?? getPredefinedConfig(_id)?.baseUrl;
  }

  /// Sets the base-url of this app.
  Future<void> updateBaseUrl(Uri? url) {
    assert(!locked);
    Uri? fallback = getPredefinedConfig(_id)?.baseUrl;
    return _setString(
      "baseUrl",
      url == fallback ? null : url?.toString(),
    );
  }

  /// {@template app.username}
  /// The optional username of this app.
  ///
  /// Used to auto-login in the app server.
  /// {@endtemplate}
  String? get username => _getString("username") ?? getPredefinedConfig(_id)?.username;

  /// Sets the username of this app.
  Future<void> updateUsername(String? username) {
    String? fallback = getPredefinedConfig(_id)?.username;
    return _setString(
      "username",
      username == fallback ? null : username?.toString(),
    );
  }

  /// {@template app.password}
  /// The optional password of this app.
  ///
  /// Used to auto-login in the app server.
  /// {@endtemplate}
  String? get password => _getString("password") ?? getPredefinedConfig(_id)?.password;

  /// Sets the name of this app.
  Future<void> updatePassword(String? password) {
    String? fallback = getPredefinedConfig(_id)?.password;
    return _setString(
      "password",
      password == fallback ? null : password?.toString(),
    );
  }

  /// {@template app.title}
  /// The title of this app.
  ///
  /// Shown in the [AppOverviewPage].
  /// {@endtemplate}
  String? get title => _getString("title") ?? getPredefinedConfig(_id)?.title;

  /// Sets the name of this app.
  Future<void> updateTitle(String? title) {
    assert(!locked);
    String? fallback = getPredefinedConfig(_id)?.title;
    return _setString(
      "title",
      title == fallback ? null : title?.toString(),
    );
  }

  /// {@template app.icon}
  /// The icon of this app.
  ///
  /// This can either be a full url or a JVx resource path.
  ///
  /// Shown in the [AppOverviewPage].
  /// {@endtemplate}
  String? get icon => _getString("icon") ?? getPredefinedConfig(_id)?.icon;

  /// Sets the name of this app.
  Future<void> updateIcon(String? icon) {
    assert(!locked);
    String? fallback = getPredefinedConfig(_id)?.icon;
    return _setString(
      "icon",
      icon == fallback ? null : icon?.toString(),
    );
  }

  /// {@template app.default}
  /// Whether this app should be viewed as the default app.
  ///
  /// Shown in the [AppOverviewPage].
  /// {@endtemplate}
  bool get isDefault {
    return ConfigController().defaultApp.value == _id;
  }

  /// Sets the name of this app.
  Future<void> updateDefault(bool? isDefault) async {
    assert(!locked);
    if (isDefault ?? false) {
      await ConfigController().updateDefaultApp(_id);
    } else {
      if (this.isDefault) {
        await ConfigController().updateDefaultApp(null);
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
      (!predefined && !customAppsAllowed);

  /// {@template app.parametersHidden}
  /// Whether the parameters such as [name] or
  /// [baseUrl] can be seen by the user.
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
  String? get version => _getString("version");

  /// {@template app.applicationStyle}
  /// The style settings of this app, if saved.
  /// {@endtemplate}
  Map<String, String>? get applicationStyle {
    String? jsonMap = _getString("applicationStyle");
    return (jsonMap != null ? Map<String, String>.from(jsonDecode(jsonMap)) : null);
  }

  /// Retrieves a bool value by it's key in connection to the app id in [SharedPreferences].
  ///
  /// If [_id] is null or [usesUserParameter] is false, this returns null.
  ///
  /// {@macro app.key}
  bool? _getBool(String key) {
    return !usesUserParameter ? null : (_id != null ? _sharedPrefs.getBool("$_id.$key") : null);
  }

  /// Retrieves a string value by it's key in connection to the app id in [SharedPreferences].
  ///
  /// If [_id] is null or [usesUserParameter] is false, this returns null.
  ///
  /// {@macro app.key}
  String? _getString(String key) {
    return !usesUserParameter ? null : (_id != null ? _sharedPrefs.getString("$_id.$key") : null);
  }

  /// Persists a string value by it's key in connection to the app id in [SharedPreferences].
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
    if (value != null) {
      return _sharedPrefs.setString("$prefix.$key", value);
    } else {
      return _sharedPrefs.remove("$prefix.$key");
    }
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

  /// Whether this config contains enough information to send a [ApiStartUpRequest].
  bool get isStartable => (name?.isNotEmpty ?? false) && baseUrl != null;

  String? get effectiveTitle => title ?? applicationStyle?["login.title"] ?? name;

  /// Updates the id of the this app.
  ///
  /// **Attention:** Check if this is really necessary before using that method!
  Future<void> updateId(String newAppId) async {
    _checkId();
    assert(!predefined && !locked, "Can't update ID of predefined app.");

    String oldAppId = _id!;

    await Future.wait(
      _sharedPrefs.getKeys().where((e) => e.startsWith("$oldAppId.")).map((e) async {
        var value = _sharedPrefs.get(e);
        await _sharedPrefs.remove(e);
        assert(value != null);

        String subKey = e.substring(e.indexOf(".")); // e.g. ".baseUrl"
        String newKey = newAppId + subKey;

        if (value is String) {
          await _sharedPrefs.setString(newKey, value);
        } else if (value is bool) {
          await _sharedPrefs.setBool(newKey, value);
        } else if (value is int) {
          await _sharedPrefs.setInt(newKey, value);
        } else if (value is double) {
          await _sharedPrefs.setDouble(newKey, value);
        } else if (value is List<String>) {
          await _sharedPrefs.setStringList(newKey, value);
        } else {
          assert(false, "${value.runtimeType} is not supported by SharedPreferences");
        }
      }).toList(),
    );

    String? currentApp = ConfigController().currentApp.value;
    if (currentApp == oldAppId) {
      await ConfigController().updateCurrentApp(newAppId);
    }
    String? lastApp = ConfigController().lastApp.value;
    if (lastApp == oldAppId) {
      await ConfigController().updateLastApp(newAppId);
    }
    String? defaultApp = ConfigController().defaultApp.value;
    if (defaultApp == oldAppId) {
      await ConfigController().updateDefaultApp(newAppId);
    }

    await ConfigController().getFileManager().renameIndependentDirectory(
        [oldAppId], id).catchError((e, stack) => FlutterUI.log.w("Failed to move app directory ($id)", e, stack));

    _id = newAppId;
  }

  /// Deletes this app.
  ///
  /// In case this is a predefined app, removes every persisted data from the storage.
  ///
  /// If this was a custom app the object becomes unusable after this action and may be discarded.
  Future<void> delete({bool forced = false}) {
    _checkId();

    assert(() {
      if (forced) return true;
      return !locked;
    }());

    String appId = _id!;
    if (!predefined) {
      // Disables this object.
      _id = null;
    }

    return Future.wait(
      _sharedPrefs.getKeys().where((e) => e.startsWith("$appId.")).map((e) => _sharedPrefs.remove(e)).toList(),
    ).then((_) async {
      if (ConfigController().defaultApp.value == appId) {
        await ConfigController().updateDefaultApp(null);
      }
      if (ConfigController().lastApp.value == appId) {
        await ConfigController().updateLastApp(null);
      }

      await ConfigController().getFileManager().deleteIndependentDirectory([appId], recursive: true).catchError(
          (e, stack) => FlutterUI.log.w("Failed to delete app directory ($appId)", e, stack));
    });
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is App && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
