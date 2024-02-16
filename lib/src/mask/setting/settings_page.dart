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

import 'dart:async';
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
import '../../service/apps/i_app_service.dart';
import '../../service/config/i_config_service.dart';
import '../../service/ui/i_ui_service.dart';
import '../../util/extensions/string_extensions.dart';
import '../../util/image/image_loader.dart';
import '../../util/jvx_colors.dart';
import '../state/loading_bar.dart';
import 'widgets/setting_group.dart';
import 'widgets/setting_item.dart';

/// Displays all settings of the app.
class SettingsPage extends StatefulWidget {
  final VoidCallback? onClosed;

  const SettingsPage({super.key, this.onClosed});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  static const double linkIconSize = 18;
  static const double arrowIconSize = 20;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final List<int> resolutions = [1024, 640, 320];

  late final Future<String> appFuture;
  late final Future<String> versionFuture;

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

    IUiService().getAppManager()?.onSettingPage();

    // Load Version
    versionFuture = PackageInfo.fromPlatform().then((packageInfo) {
      int? buildNumber = IConfigService().getAppConfig()?.versionConfig?.buildNumber;
      String effectiveBuildNumber =
          buildNumber != null && buildNumber >= 0 ? buildNumber.toString() : packageInfo.buildNumber;
      return "${packageInfo.version}${effectiveBuildNumber == "" ? "" : "-$effectiveBuildNumber"}";
    });

    appName = IConfigService().appName.value;
    baseUrl = IConfigService().baseUrl.value;
    language = IConfigService().userLanguage.value;
    singleAppMode = IConfigService().singleAppMode.value;
  }

  @override
  Widget build(BuildContext context) {
    Widget widget = Builder(
      builder: (context) {
        Widget body = SingleChildScrollView(
          child: Column(
            children: [
              _buildApplicationInfo(),
              if (appName != null)
                IconTheme.merge(
                  data: IconThemeData(color: Theme.of(context).colorScheme.primary),
                  child: Builder(builder: (context) => _buildGeneralSettings(context)),
                ),
              IconTheme.merge(
                data: IconThemeData(color: Theme.of(context).colorScheme.primary),
                child: Builder(builder: (context) => _buildApplicationSettings(context)),
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

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            leading: IconButton(
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              splashRadius: kToolbarHeight / 2,
              icon: const BackButtonIcon(),
              onPressed: routeBack,
            ),
            title: Text(FlutterUI.translateLocal("Settings")),
            elevation: 0,
          ),
          body: body,
          bottomNavigationBar: Theme(
            data: Theme.of(context).copyWith(
              textTheme: Theme.of(context).primaryTextTheme,
              iconTheme: Theme.of(context).primaryIconTheme,
            ),
            child: Material(
              color: JVxColors.isLightTheme(context) ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
              child: SafeArea(
                child: SizedBox(
                  height: bottomBarHeight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (_changesPending()) Expanded(child: _createCancelButton(context)),
                      if (_changesPending())
                        VerticalDivider(
                          color: JVxColors.dividerColor(Theme.of(context)),
                          width: 1,
                        ),
                      Expanded(child: _createSaveButton(context)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (IConfigService().currentApp.value == null) {
      widget = Theme(
        data: JVxColors.applyJVxTheme(ThemeData(
          colorScheme: ColorScheme.fromSeed(
            brightness: Theme.of(context).colorScheme.brightness,
            seedColor: Colors.blue,
          ),
        )),
        child: widget,
      );
    }
    return widget;
  }

  Widget _createCancelButton(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: bottomBarHeight),
      child: InkWell(
        onTap: routeBack,
        child: SizedBox.shrink(
          child: Center(
            child: Text(
              FlutterUI.translateLocal("Cancel"),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _createSaveButton(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: bottomBarHeight),
      child: InkWell(
        onTap: _saveClicked,
        child: SizedBox.shrink(
          child: Center(
            child: Text(
              FlutterUI.translateLocal(_changesPending() ? "Save" : "OK"),
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
    if (IConfigService().privacyPolicy.value != null) {
      SettingItem privacyPolicy = SettingItem(
        frontIcon: const FaIcon(FontAwesomeIcons.link, size: 19),
        endIcons: const [FaIcon(FontAwesomeIcons.arrowUpRightFromSquare, size: linkIconSize, color: Colors.grey)],
        title: FlutterUI.translateLocal("Privacy Policy"),
        onPressed: (context, value) => launchUrl(
          IConfigService().privacyPolicy.value!,
          mode: LaunchMode.externalApplication,
        ),
      );

      return SettingGroup(
        groupHeader: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            FlutterUI.translateLocal("Information"),
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

  Widget _buildGeneralSettings(BuildContext context) {
    SettingItem? appNameSetting;
    bool hideAppDetails = IConfigService().parametersHidden.value!;

    if (!hideAppDetails) {
      appNameSetting = SettingItem(
        enabled: false,
        frontIcon: const FaIcon(FontAwesomeIcons.cubes),
        value: appName ?? "",
        title: FlutterUI.translateLocal("App name"),
      );
    }

    String urlTitle = FlutterUI.translateLocal("URL");
    SettingItem? baseUrlSetting;
    if (!hideAppDetails) {
      baseUrlSetting = SettingItem(
        enabled: false,
        frontIcon: const FaIcon(FontAwesomeIcons.globe),
        value: baseUrl?.toString() ?? "",
        title: urlTitle,
      );
    }

    Widget? languageSetting;
    if (!(IConfigService().customLanguage.value ?? false) &&
        !(IConfigService().getAppConfig()?.uiConfig?.hideLanguageSetting ?? false)) {
      var supportedLanguages = IConfigService().supportedLanguages.value.toList();
      supportedLanguages.insertAll(0, [
        "${FlutterUI.translateLocal("System")} (${IConfigService().getPlatformLocale()})",
        "en",
      ]);

      var userLanguage = IConfigService().userLanguage.value;

      languageSetting = _buildPickerItem<String>(
        context,
        frontIcon: FontAwesomeIcons.language,
        endIcons: (userLanguage ?? IConfigService().getPlatformLocale()) != IConfigService().getLanguage()
            ? [_buildOverrideIcon()]
            : null,
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
    }

    Widget? pictureSizeSetting;
    if (!(IConfigService().getAppConfig()?.uiConfig?.hidePictureSizeSetting ?? false)) {
      var resolution = IConfigService().pictureResolution.value ?? resolutions[0];
      pictureSizeSetting = _buildPickerItem<int>(
        context,
        frontIcon: FontAwesomeIcons.image,
        title: "Picture Size",
        value: resolution,
        itemBuilder: <int>(BuildContext context, int value, Widget? widget) =>
            Text("$value ${FlutterUI.translateLocal("px")}"),
        onPressed: (context, value) {
          var items = resolutions.map((e) => "$e ${FlutterUI.translateLocal("px")}").toList();
          _openDropdown(context, items, "$e ${FlutterUI.translateLocal("px")}", onValue: (selectedResolution) async {
            resolution = int.parse(selectedResolution.split(" ")[0]);
            await IConfigService().updatePictureResolution(resolution);
            setState(() {});
          });
        },
      );
    }

    var items = [
      if (appNameSetting != null) appNameSetting,
      if (baseUrlSetting != null) baseUrlSetting,
      if (languageSetting != null) languageSetting,
      if (pictureSizeSetting != null) pictureSizeSetting,
    ];

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return SettingGroup(
      groupHeader: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          FlutterUI.translateLocal("General"),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      items: items,
    );
  }

  Widget _buildApplicationSettings(BuildContext context) {
    Widget? singleAppSetting;
    if (IConfigService().showSingleAppModeSwitch()) {
      singleAppSetting = SwitchListTile.adaptive(
        contentPadding: const EdgeInsets.only(left: 21, right: 5, top: 5, bottom: 5),
        secondary: Icon(Icons.apps, color: Theme.of(context).colorScheme.primary),
        title: Text(FlutterUI.translateLocal("Manage single application")),
        value: singleAppMode,
        onChanged: (value) {
          IConfigService().updateSingleAppMode(value);
          setState(() {
            singleAppMode = value;
          });
        },
      );
    }

    Widget? themeSetting;
    if (!(IConfigService().getAppConfig()?.uiConfig?.hideThemeSetting ?? false)) {
      final Brightness systemBrightness = MediaQuery.platformBrightnessOf(context);
      final Map<ThemeMode, String> themeMapping = {
        ThemeMode.system:
            "${FlutterUI.translateLocal("System")} (${FlutterUI.translateLocal(systemBrightness.name.capitalize())})",
        ThemeMode.light: FlutterUI.translateLocal("Light"),
        ThemeMode.dark: FlutterUI.translateLocal("Dark"),
      };

      var theme = IConfigService().themePreference.value;
      IconData themeIcon = FontAwesomeIcons.sun;
      if (theme == ThemeMode.light) themeIcon = FontAwesomeIcons.solidSun;
      if (theme == ThemeMode.dark) themeIcon = FontAwesomeIcons.solidMoon;

      themeSetting = _buildPickerItem<ThemeMode>(
        context,
        frontIcon: themeIcon,
        endIcons: theme != IConfigService().getThemeMode() ? [_buildOverrideIcon()] : null,
        title: "Theme",
        value: theme,
        itemBuilder: (BuildContext context, value, Widget? widget) => Text(themeMapping[value]!),
        onPressed: (context, value) {
          var items = ThemeMode.values.where((e) => themeMapping.containsKey(e)).map((e) => themeMapping[e]!).toList();
          _openDropdown(context, items, themeMapping[value], onValue: (selectedThemeMode) async {
            theme = themeMapping.entries.firstWhere((entry) => entry.value == selectedThemeMode).key;
            await IConfigService().updateThemePreference(theme);
            setState(() {});
          });
        },
      );
    }

    var items = [
      if (singleAppSetting != null) singleAppSetting,
      if (themeSetting != null) themeSetting,
    ];

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return SettingGroup(
      groupHeader: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          FlutterUI.translateLocal("Application"),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      items: items,
    );
  }

  SettingItem _buildPickerItem<T>(
    BuildContext context, {
    required IconData frontIcon,
    List<Widget>? endIcons,
    required String title,
    required T value,
    required Function(BuildContext context, T value) onPressed,
    ValueWidgetBuilder<T>? itemBuilder,
  }) =>
      SettingItem<T>(
        frontIcon: FaIcon(frontIcon, color: Theme.of(context).colorScheme.primary),
        endIcons: [
          ...?endIcons,
          const FaIcon(FontAwesomeIcons.circleChevronDown, size: arrowIconSize, color: Colors.grey),
        ],
        title: FlutterUI.translateLocal(title),
        value: value,
        itemBuilder: itemBuilder,
        onPressed: onPressed,
      );

  Widget _buildOverrideIcon() {
    return Tooltip(
      message: FlutterUI.translateLocal("Overridden by the application"),
      child: const Icon(Icons.hide_source, size: 18),
    );
  }

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
    Widget appVersionSetting = FutureBuilder(
        future: versionFuture,
        builder: (context, snapshot) {
          return SettingItem(
            frontIcon: const FaIcon(FontAwesomeIcons.github),
            endIcons: const [FaIcon(FontAwesomeIcons.arrowUpRightFromSquare, size: linkIconSize, color: Colors.grey)],
            value: snapshot.data ?? FlutterUI.translateLocal("Loading..."),
            title: FlutterUI.translateLocal("App Version"),
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
        });

    SettingItem commitSetting = SettingItem(
      frontIcon: const FaIcon(FontAwesomeIcons.codeBranch),
      value: IConfigService().getAppConfig()?.versionConfig?.commit ?? "",
      title: FlutterUI.translateLocal("RCS"),
    );

    SettingItem buildDataSetting = SettingItem(
      frontIcon: const FaIcon(FontAwesomeIcons.calendar),
      value: IConfigService().getAppConfig()?.versionConfig?.buildDate ?? "",
      title: FlutterUI.translateLocal("Build date"),
    );

    return SettingGroup(
      groupHeader: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          FlutterUI.translateLocal("Version Info"),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      items: [appVersionSetting, commitSetting, buildDataSetting],
    );
  }

  Widget _buildStatus(BuildContext context) {
    String versionValue;
    if (appName != null) {
      versionValue = (IUiService().applicationMetaData.value?.serverVersion ?? FlutterUI.translateLocal("Unknown"));
      if (IUiService().applicationMetaData.value?.serverVersion != FlutterUI.supportedServerVersion) {
        versionValue += " (${FlutterUI.translateLocal("Supported")}: ${FlutterUI.supportedServerVersion})";
      }
    } else {
      versionValue = "${FlutterUI.translateLocal("Supported")}: ${FlutterUI.supportedServerVersion}";
    }

    SettingItem serverVersion = SettingItem(
      frontIcon: const FaIcon(FontAwesomeIcons.server),
      title: FlutterUI.translateLocal("Server Version"),
      value: versionValue,
    );

    Widget buildWebSocketStatus() {
      OnlineApiRepository? repository;
      if (IApiService().getRepository() is OnlineApiRepository) {
        repository = IApiService().getRepository() as OnlineApiRepository;
      }

      return AnimatedBuilder(
        animation: Listenable.merge([
          repository?.getWebSocket()?.available,
          repository?.getWebSocket()?.connected,
        ]),
        builder: (context, child) => _buildWebSocketStatus(
          repository?.getWebSocket()?.connected.value,
        ),
      );
    }

    return SettingGroup(
      groupHeader: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          FlutterUI.translateLocal("Status"),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      items: [
        serverVersion,
        if (appName != null) buildWebSocketStatus(),
      ],
    );
  }

  SettingItem<String> _buildWebSocketStatus(bool? connected) {
    String text = FlutterUI.translateLocal(connected != null ? (connected ? "Available" : "Not available") : "Unknown");
    return SettingItem(
      frontIcon: const FaIcon(FontAwesomeIcons.circleNodes),
      title: FlutterUI.translateLocal("Web Socket"),
      value: text,
      onPressed: !(connected ?? false) && IApiService().getRepository() is OnlineApiRepository
          ? (context, value) async {
              await (IApiService().getRepository() as OnlineApiRepository?)?.startWebSocket().catchError(
                  (e, stack) => FlutterUI.logAPI.w("Manual WebSocket connection failed", error: e, stackTrace: stack));
              setState(() {});
            }
          : null,
    );
  }

  bool _changesPending() {
    return language != IConfigService().userLanguage.value;
  }

  /// Will send a [StartupCommand] with current values
  Future<void> _saveClicked() async {
    try {
      if (_changesPending()) {
        await IConfigService().updateUserLanguage(language);
        if (!IConfigService().offline.value && IUiService().clientId.value != null) {
          unawaited(IAppService().startApp());
          return;
        }
      }

      await routeBack();
    } catch (e, stackTrace) {
      IUiService().showErrorDialog(error: e, stackTrace: stackTrace);
    }
  }

  Future<void> routeBack() async {
    if (!mounted) return;

    if (widget.onClosed != null) {
      widget.onClosed!();
    } else if (!context.beamBack()) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else if (IUiService().canRouteToAppOverview()) {
        await IUiService().routeToAppOverview();
      }
    }
  }
}
