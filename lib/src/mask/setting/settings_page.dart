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

import 'dart:math';

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../flutter_ui.dart';
import '../../model/command/api/startup_command.dart';
import '../../service/api/i_api_service.dart';
import '../../service/api/shared/repository/online_api_repository.dart';
import '../../service/config/config_controller.dart';
import '../../service/ui/i_ui_service.dart';
import '../../util/image/image_loader.dart';
import '../../util/jvx_colors.dart';
import '../state/loading_bar.dart';
import 'widgets/setting_group.dart';
import 'widgets/setting_item.dart';

/// Displays all settings of the app
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const double endIconSize = 20;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final List<int> resolutions = [1024, 640, 320];

  /// App version notifier
  late ValueNotifier<String> appVersionNotifier;

  late final String? appName;
  late final Uri? baseUrl;
  String? language;
  late bool singleAppMode;

  static const double bottomBarHeight = 55;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    super.initState();

    // Load Version
    appVersionNotifier = ValueNotifier("${FlutterUI.translate("Loading")}...");
    PackageInfo.fromPlatform().then((packageInfo) {
      int? buildNumber = ConfigController().getAppConfig()?.versionConfig?.buildNumber;
      String effectiveBuildNumber =
          buildNumber != null && buildNumber >= 0 ? buildNumber.toString() : packageInfo.buildNumber;
      return appVersionNotifier.value =
          "${packageInfo.version}${effectiveBuildNumber == "" ? "" : "-$effectiveBuildNumber"}";
    });

    appName = ConfigController().appName.value;
    baseUrl = ConfigController().baseUrl.value;
    language = ConfigController().userLanguage.value;
    singleAppMode = ConfigController().singleAppMode.value;
  }

  @override
  Widget build(BuildContext context) {
    Widget body = SingleChildScrollView(
      child: Column(
        children: [
          _buildApplicationInfo(),
          if (appName != null)
            IconTheme.merge(
              data: IconThemeData(color: Theme.of(context).colorScheme.primary),
              child: Builder(builder: (context) => _buildApplicationSettings(context)),
            ),
          IconTheme.merge(
            data: IconThemeData(color: Theme.of(context).colorScheme.primary),
            child: Builder(builder: (context) => _buildDeviceSettings(context)),
          ),
          _buildVersionInfo(),
          IconTheme.merge(
            data: IconThemeData(color: Theme.of(context).colorScheme.primary),
            child: Builder(builder: (context) => _buildStatus(context)),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );

    body = LoadingBar.wrapLoadingBar(body);

    bool loading = LoadingBar.maybeOf(context)?.show ?? false;

    return WillPopScope(
      onWillPop: () async => !loading,
      child: Scaffold(
        appBar: AppBar(
          leading: context.canBeamBack
              ? IconButton(
                  icon: const FaIcon(FontAwesomeIcons.arrowLeft),
                  onPressed: context.beamBack,
                )
              : null,
          title: Text(FlutterUI.translate("Settings")),
          elevation: 0,
        ),
        body: body,
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            textTheme: Theme.of(context).primaryTextTheme,
            iconTheme: Theme.of(context).primaryIconTheme,
          ),
          child: Material(
            color: Theme.of(context).colorScheme.brightness == Brightness.light
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surface,
            child: SafeArea(
              child: SizedBox(
                height: bottomBarHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(child: _createCancelButton(context)),
                    if (context.canBeamBack && _changesPending())
                      VerticalDivider(
                        color: JVxColors.dividerColor(Theme.of(context)),
                        width: 1,
                      ),
                    if (!context.canBeamBack || !_changesPending()) const SizedBox(width: 16.0),
                    Expanded(child: _createSaveButton(context)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _createCancelButton(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: bottomBarHeight),
      child: context.canBeamBack && _changesPending()
          ? InkWell(
              onTap: context.beamBack,
              child: SizedBox.shrink(
                child: Center(
                  child: Text(
                    FlutterUI.translate("Cancel"),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _createSaveButton(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: bottomBarHeight),
      child: InkWell(
        onTap: ConfigController().offline.value ? () => context.beamBack() : _saveClicked,
        child: SizedBox.shrink(
          child: Center(
            child: Text(
              FlutterUI.translate(_changesPending() ? "Save" : "OK"),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Widget _buildApplicationInfo() {
    if (ConfigController().getAppConfig()?.privacyPolicy != null) {
      SettingItem privacyPolicy = SettingItem(
        frontIcon: const FaIcon(FontAwesomeIcons.link),
        endIcon: const FaIcon(FontAwesomeIcons.arrowUpRightFromSquare, size: endIconSize, color: Colors.grey),
        title: FlutterUI.translate("Privacy Policy"),
        onPressed: (context, value) => launchUrl(
          ConfigController().getAppConfig()!.privacyPolicy!,
          mode: LaunchMode.externalApplication,
        ),
      );

      return SettingGroup(
        groupHeader: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            FlutterUI.translate("Info"),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        items: [privacyPolicy],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildApplicationSettings(BuildContext context) {
    SettingItem? appNameSetting;
    bool hideAppDetails =
        !ConfigController().getAppConfig()!.configsHidden! && !(ConfigController().hidden.value ?? false);

    if (hideAppDetails) {
      appNameSetting = SettingItem(
        enabled: false,
        frontIcon: const FaIcon(FontAwesomeIcons.cubes),
        value: appName ?? "",
        title: FlutterUI.translate("App Name"),
      );
    }

    String urlTitle = FlutterUI.translate("URL");
    SettingItem? baseUrlSetting;
    if (hideAppDetails) {
      baseUrlSetting = SettingItem(
        enabled: false,
        frontIcon: const FaIcon(FontAwesomeIcons.globe),
        value: baseUrl?.toString() ?? "",
        title: urlTitle,
      );
    }

    var supportedLanguages = ConfigController().supportedLanguages.value.toList();
    supportedLanguages.insertAll(0, [
      "${FlutterUI.translate("System")} (${ConfigController().getPlatformLocale()})",
      "en",
    ]);

    SettingItem languageSetting = _buildPickerItem<String>(
      frontIcon: FontAwesomeIcons.language,
      title: "Language",
      // "System" is default
      value: language ?? supportedLanguages[0],
      onPressed: (context, value) {
        _openDropdown(context, supportedLanguages, value, onValue: (selectedLanguage) {
          if (selectedLanguage == supportedLanguages[0]) {
            // "System" selected
            language = null;
          } else {
            language = selectedLanguage;
          }
          setState(() {});
        });
      },
    );

    return SettingGroup(
      groupHeader: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          ConfigController().title.value ?? FlutterUI.translate("Application"),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      items: [
        if (appNameSetting != null) appNameSetting,
        if (baseUrlSetting != null) baseUrlSetting,
        languageSetting,
      ],
    );
  }

  _buildDeviceSettings(BuildContext context) {
    Widget singleAppSetting = SwitchListTile(
      contentPadding: const EdgeInsets.only(left: 21, right: 5, top: 5, bottom: 5),
      secondary: Icon(Icons.apps, color: Theme.of(context).colorScheme.primary),
      title: Text(FlutterUI.translate("Manage single application")),
      value: singleAppMode,
      onChanged: (value) {
        ConfigController().updateSingleAppMode(value);
        setState(() {
          singleAppMode = value;
        });
      },
    );

    final Map<ThemeMode, String> themeMapping = {
      ThemeMode.system: FlutterUI.translate("System"),
      ThemeMode.light: FlutterUI.translate("Light"),
      ThemeMode.dark: FlutterUI.translate("Dark"),
    };

    var theme = ConfigController().themePreference.value;
    IconData themeIcon = FontAwesomeIcons.sun;
    if (theme == ThemeMode.light) themeIcon = FontAwesomeIcons.solidSun;
    if (theme == ThemeMode.dark) themeIcon = FontAwesomeIcons.solidMoon;

    SettingItem themeSetting = _buildPickerItem<ThemeMode>(
      frontIcon: themeIcon,
      title: "Theme",
      value: theme,
      itemBuilder: (BuildContext context, value, Widget? widget) => Text(themeMapping[value]!),
      onPressed: (context, value) {
        var items = ThemeMode.values.where((e) => themeMapping.containsKey(e)).map((e) => themeMapping[e]!).toList();
        _openDropdown(context, items, themeMapping[value], onValue: (selectedThemeMode) async {
          theme = themeMapping.entries.firstWhere((entry) => entry.value == selectedThemeMode).key;
          await ConfigController().updateThemePreference(theme);
          setState(() {});
        });
      },
    );

    var resolution = ConfigController().pictureResolution.value ?? resolutions[0];
    SettingItem pictureSetting = _buildPickerItem<int>(
      frontIcon: FontAwesomeIcons.image,
      title: "Picture Size",
      value: resolution,
      itemBuilder: <int>(BuildContext context, int value, Widget? widget) => Text(FlutterUI.translate("$value px")),
      onPressed: (context, value) {
        var items = resolutions.map((e) => "$e px").toList();
        _openDropdown(context, items, "$value px", onValue: (selectedResolution) async {
          resolution = int.parse(selectedResolution.split(" ")[0]);
          await ConfigController().updatePictureResolution(resolution);
          setState(() {});
        });
      },
    );

    return SettingGroup(
      groupHeader: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          FlutterUI.translate("Device"),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      items: [singleAppSetting, themeSetting, pictureSetting],
    );
  }

  SettingItem _buildPickerItem<T>({
    required IconData frontIcon,
    required String title,
    required T value,
    required Function(BuildContext context, T value) onPressed,
    ValueWidgetBuilder<T>? itemBuilder,
  }) =>
      SettingItem<T>(
        frontIcon: FaIcon(frontIcon, color: Theme.of(context).colorScheme.primary),
        endIcon: const FaIcon(FontAwesomeIcons.circleChevronDown, size: endIconSize, color: Colors.grey),
        title: FlutterUI.translate(title),
        value: value,
        itemBuilder: itemBuilder,
        onPressed: onPressed,
      );

  void _openDropdown(
    BuildContext context,
    List<String> items,
    String? value, {
    required void Function(String selectedValue) onValue,
  }) {
    // Copied from [PopupMenuButtonState]
    if (items.isNotEmpty) {
      final PopupMenuThemeData popupMenuTheme = PopupMenuTheme.of(context);
      final RenderBox button = context.findRenderObject()! as RenderBox;
      final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;

      var offset = value != null
          ? Offset(button.size.width, 0.0)
          : Offset(button.size.width, const EdgeInsets.all(6.0).vertical);

      final RelativeRect position = RelativeRect.fromRect(
        Rect.fromPoints(
          button.localToGlobal(offset, ancestor: overlay),
          button.localToGlobal(button.size.bottomRight(Offset.zero) + offset, ancestor: overlay),
        ),
        Offset.zero & overlay.size,
      );

      showMenu<String>(
        context: context,
        initialValue: value,
        items: items.map((e) => PopupMenuItem<String>(value: e, child: Text(e))).toList(),
        position: position,
        shape: popupMenuTheme.shape,
        color: popupMenuTheme.color,
      ).then<void>((String? selectedValue) {
        if (selectedValue != null) {
          onValue.call(selectedValue);
        }
      });
    }
  }

  Widget _buildVersionInfo() {
    SettingItem appVersionSetting = SettingItem(
      frontIcon: const FaIcon(FontAwesomeIcons.github),
      endIcon: const FaIcon(FontAwesomeIcons.arrowUpRightFromSquare, size: endIconSize, color: Colors.grey),
      valueNotifier: appVersionNotifier,
      title: FlutterUI.translate("App Version"),
      onPressed: (context, value) => showLicensePage(
        context: context,
        applicationIcon: Builder(builder: (context) {
          double size = IconTheme.of(context).size ?? 24;
          return SvgPicture.asset(
            ImageLoader.getAssetPath(
              FlutterUI.package,
              "assets/images/J.svg",
            ),
            height: max(80, size),
          );
        }),
      ),
    );

    SettingItem commitSetting = SettingItem(
      frontIcon: const FaIcon(FontAwesomeIcons.codeBranch),
      value: ConfigController().getAppConfig()?.versionConfig?.commit ?? "",
      title: FlutterUI.translate("RCS"),
    );

    SettingItem buildDataSetting = SettingItem(
      frontIcon: const FaIcon(FontAwesomeIcons.calendar),
      value: ConfigController().getAppConfig()?.versionConfig?.buildDate ?? "",
      title: FlutterUI.translate("Build date"),
    );

    return SettingGroup(
      groupHeader: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          FlutterUI.translate("Version Info"),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      items: [appVersionSetting, commitSetting, buildDataSetting],
    );
  }

  _buildStatus(BuildContext context) {
    String versionValue = (IUiService().applicationMetaData.value?.serverVersion ?? "Unknown");
    if (IUiService().applicationMetaData.value?.serverVersion != FlutterUI.supportedServerVersion) {
      versionValue += " (${FlutterUI.translate("Supported")}: ${FlutterUI.supportedServerVersion})";
    }

    SettingItem serverVersion = SettingItem(
      frontIcon: const FaIcon(FontAwesomeIcons.server),
      title: FlutterUI.translate("Server Version"),
      value: versionValue,
    );

    OnlineApiRepository? repository;
    if (IApiService().getRepository() is OnlineApiRepository) {
      repository = IApiService().getRepository() as OnlineApiRepository;
    }

    Widget webSocketStatus = AnimatedBuilder(
      animation: Listenable.merge([
        repository?.getWebSocket()?.available,
        repository?.getWebSocket()?.connected,
      ]),
      builder: (context, child) => _buildWebSocketStatus(
        repository?.getWebSocket()?.available.value,
        repository?.getWebSocket()?.connected.value,
      ),
    );

    return SettingGroup(
      groupHeader: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          FlutterUI.translate("Status"),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      items: [
        serverVersion,
        webSocketStatus,
      ],
    );
  }

  SettingItem<String> _buildWebSocketStatus(bool? available, bool? connected) {
    String text = FlutterUI.translate(available != null ? (available ? "Available" : "Not available") : "Unknown");
    if (connected != null) {
      text += " (${FlutterUI.translate(connected ? "Connected" : "Not connected")})";
    }
    return SettingItem(
      frontIcon: const FaIcon(FontAwesomeIcons.circleNodes),
      title: FlutterUI.translate("Web Socket"),
      value: text,
      onPressed: !(connected ?? false) && IApiService().getRepository() is OnlineApiRepository
          ? (context, value) async {
              await (IApiService().getRepository() as OnlineApiRepository?)
                  ?.startWebSocket()
                  .catchError((e, stack) => FlutterUI.logAPI.w("Manual WebSocket connection failed", e, stack));
              setState(() {});
            }
          : null,
    );
  }

  bool _changesPending() {
    return language != ConfigController().userLanguage.value;
  }

  /// Will send a [StartupCommand] with current values
  Future<void> _saveClicked() async {
    try {
      BeamerDelegate beamer = Beamer.of(context);
      if (_changesPending()) {
        await ConfigController().updateUserLanguage(language);
        if (IUiService().clientId.value != null) {
          FlutterUI.of(FlutterUI.getCurrentContext()!).startApp();
          return;
        }
      }

      if (beamer.canBeamBack) {
        beamer.beamBack();
      } else {
        await IUiService().routeToAppOverview();
      }
    } catch (e, stackTrace) {
      IUiService().handleAsyncError(e, stackTrace);
    }
  }
}
