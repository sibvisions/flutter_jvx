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

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../config/application_config.dart';
import '../../config/server_config.dart';
import '../../flutter_ui.dart';
import '../../service/config/config_controller.dart';
import '../../service/ui/i_ui_service.dart';
import '../../util/image/image_loader.dart';
import '../../util/jvx_colors.dart';
import '../camera/qr_parser.dart';
import '../camera/qr_scanner_overlay.dart';
import 'app_edit_dialog.dart';
import 'app_item.dart';
import 'select_item.dart';
import 'single_app_view.dart';

class AppOverviewPage extends StatefulWidget {
  const AppOverviewPage({super.key});

  static const IconData appsIcon = Icons.window;

  static bool showAppsButton() =>
      ConfigController().getAppConfig()!.customAppsAllowed! ||
      !ConfigController().getAppConfig()!.serverConfigsLocked! ||
      ConfigController().getAppNames().length > 1;

  static ImageProvider? getAppIcon(ServerConfig? config) {
    if (config == null) return null;
    String? styleIcon = ConfigController().getAppStyle(config.appName)?["icon"];
    return ((config.icon != null && config.appName != null && config.baseUrl != null) || styleIcon != null
        ? ImageLoader.getImageProvider(
            styleIcon ?? config.icon!,
            appName: config.appName,
            baseUrl: config.baseUrl,
          )
        : null);
  }

  static Future<void> openQRScanner(
    BuildContext context, {
    required Future<void> Function(ApplicationConfig config) callback,
    bool allowMultiScan = false,
  }) {
    return IUiService().openDialog(
      context: context,
      pBuilder: (context) => QRScannerOverlay(
        allowMultiScan: allowMultiScan,
        callback: (barcodes) async {
          for (var barcode in barcodes) {
            FlutterUI.logUI.d("Parsing scanned qr code:\n\n${barcode.rawValue}");
            try {
              final ApplicationConfig config = QRParser.parse(barcode.rawValue!);
              await callback.call(config);
            } catch (e, stack) {
              FlutterUI.logUI.w("Error parsing QR Code", e, stack);
              if (barcodes.length == 1) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text(FlutterUI.translate(
                    e is FormatException
                        ? "Invalid QR Code${e.message.isNotEmpty ? ": ${e.message}" : ""}"
                        : "Failed to parse QR Code",
                  )),
                ));
              }
            }
          }
        },
      ),
    );
  }

  static Future<void> showInvalidURLDialog(BuildContext context, e) {
    return IUiService().openDialog(
      context: context,
      pBuilder: (context) => AlertDialog(
        title: Text(FlutterUI.translate("Invalid URL")),
        content: Text("${FlutterUI.translate("URL is invalid")}:\n${e.toString()}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(FlutterUI.translate("OK")),
          ),
        ],
      ),
      pIsDismissible: true,
    );
  }

  static Future<void> showRequiredFieldsDialog(BuildContext context) {
    return IUiService().openDialog(
      context: context,
      pBuilder: (context) => AlertDialog(
        title: Text(FlutterUI.translate("Missing required fields")),
        content: Text(FlutterUI.translate("You have to provide an app name and a base url to add an app.")),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(FlutterUI.translate("OK")),
          ),
        ],
      ),
      pIsDismissible: true,
    );
  }

  static bool get isSingleAppMode {
    if (ConfigController().getAppConfig()!.forceSingleAppMode!) return true;
    if (!ConfigController().getAppConfig()!.customAppsAllowed!) return false;
    return ConfigController().singleAppMode.value;
  }

  static bool get customAppsAllowed => ConfigController().getAppConfig()!.customAppsAllowed!;

  static bool get isPredefinedLocked => isPredefinedHidden || ConfigController().getAppConfig()!.serverConfigsLocked!;

  static bool get isPredefinedHidden => ConfigController().getAppConfig()!.serverConfigsParametersHidden!;

  static bool useUserSettings(bool isPredefinedLocked, bool isPredefined, ServerConfig? config) {
    return !isPredefined ||
        (isPredefined && !isPredefinedLocked && !(config?.locked ?? false) && !(config?.parametersHidden ?? false));
  }

  /// Returns if the app is locked.
  ///
  /// If it's a predefined app and this or all predefined apps are locked,
  /// or if it isn't a predefined app and customs aren't allowed.
  static bool isAppLocked(bool isPredefined, ServerConfig? config) {
    return (isPredefined && (isPredefinedLocked || (config?.locked ?? false) || (config?.parametersHidden ?? false))) ||
        (!isPredefined && !customAppsAllowed);
  }

  /// Returns if the app is hidden.
  ///
  /// If it's a predefined app and this or all predefined apps are hidden.
  static bool isAppHidden(bool isPredefined, ServerConfig? config) {
    return isPredefined && (isPredefinedHidden || (config?.parametersHidden ?? false));
  }

  @override
  State<AppOverviewPage> createState() => _AppOverviewPageState();
}

class _AppOverviewPageState extends State<AppOverviewPage> {
  late final WidgetBuilder? backgroundBuilder;
  List<ServerConfig>? apps;
  Future<void>? future;

  ServerConfig? currentConfig;

  @override
  void initState() {
    super.initState();
    backgroundBuilder = FlutterUI.of(context).widget.backgroundBuilder;
    _refreshApps();
  }

  void _refreshApps() {
    setState(() {
      future = () async {
        var retrievedApps = await FlutterUI.getApps();
        apps = [...retrievedApps];
        currentConfig = _getCurrentEditableConfig();
      }()
          .catchError(FlutterUI.createErrorHandler("Failed to init app list"));
    });
  }

  bool get containsCustomApps =>
      (apps?.where((element) => ConfigController().getPredefinedApp(element.appName) == null).isNotEmpty ?? false);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: JVxColors.applyJVxTheme(ThemeData(
        useMaterial3: true,
        colorScheme: JVxColors.applyJVxColorScheme(ColorScheme.fromSeed(
          brightness: Theme.of(context).colorScheme.brightness,
          seedColor: Colors.blue,
        )),
      )),
      child: Navigator(
        key: kDebugMode ? GlobalKey() : null,
        onGenerateRoute: (settings) => MaterialPageRoute(
          settings: settings,
          builder: (context) {
            return Scaffold(
              body: Stack(
                fit: StackFit.expand,
                children: [
                  if (backgroundBuilder != null) backgroundBuilder!.call(context),
                  if (backgroundBuilder == null)
                    SvgPicture.asset(
                      ImageLoader.getAssetPath(
                        FlutterUI.package,
                        "assets/images/JVx_Bg.svg",
                      ),
                      fit: BoxFit.fill,
                    ),
                  SafeArea(
                    child: FutureBuilder(
                      future: future,
                      builder: (context, snapshot) {
                        bool showAddOnFront = (apps?.isEmpty ?? false);

                        return Padding(
                          padding: const EdgeInsets.fromLTRB(12.0, 20.0, 12.0, 12.0),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          FlutterUI.translate(
                                              AppOverviewPage.isSingleAppMode ? "Application" : "Applications"),
                                          style: const TextStyle(
                                            color: JVxColors.LIGHTER_BLACK,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 32,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 16.0),
                                        child: _buildAppList(
                                          context,
                                          snapshot,
                                          showAddOnFront,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 0.0,
                                right: 8.0,
                                child: _buildMenuButton(
                                  context,
                                  AppOverviewPage.isSingleAppMode || showAddOnFront,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              floatingActionButton: AppOverviewPage.isSingleAppMode
                  ? FloatingActionButton(
                      tooltip: FlutterUI.translate("Scan QR Code"),
                      onPressed: () => AppOverviewPage.openQRScanner(
                        context,
                        callback: (config) async {
                          var serverConfig = config.apps?.firstOrNull;
                          if (serverConfig != null) {
                            setState(() => currentConfig = serverConfig);
                          }
                        },
                      ),
                      child: const Icon(Icons.qr_code),
                    )
                  : null,
              floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppList(BuildContext context, AsyncSnapshot snapshot, bool showAddOnFront) {
    Widget child;
    if (snapshot.hasError) {
      child = const FaIcon(FontAwesomeIcons.circleExclamation);
    } else {
      if (AppOverviewPage.isSingleAppMode) {
        child = SingleAppView(
          config: currentConfig,
          onStart: (config) async {
            bool success = await _updateApp(
              context,
              config.merge(const ServerConfig(isDefault: true)),
            );
            if (success && mounted && config.isStartable) {
              FlutterUI.of(this.context).startApp(app: config);
            }
          },
        );
      } else {
        child = CustomScrollView(
          slivers: [
            SliverPadding(
              // Padding to keep card effects visible (prevent cropping),
              // top padding is roughly half the size of the default check mark.
              padding: const EdgeInsets.only(
                top: 12,
                left: 8.0,
                right: 8.0,
                bottom: 8.0,
              ),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 0.8,
                  mainAxisSpacing: 20.0,
                  crossAxisSpacing: 20.0,
                ),
                delegate: SliverChildBuilderDelegate(
                  childCount: (apps?.length ?? 0) + (showAddOnFront ? 1 : 0),
                  (context, index) {
                    if (index < (apps?.length ?? 0)) {
                      var app = apps![index];
                      ServerConfig? predefinedApp = ConfigController().getPredefinedApp(app.appName);
                      bool isPredefined = predefinedApp != null;
                      return AppItem(
                        key: ObjectKey(app),
                        enabled: (isPredefined || AppOverviewPage.customAppsAllowed) && app.isStartable,
                        appTitle: app.effectiveTitle!,
                        image: AppOverviewPage.getAppIcon(app),
                        isDefault: app.isDefault ?? false,
                        locked: AppOverviewPage.isAppLocked(isPredefined, app),
                        predefined: isPredefined,
                        onTap: app.isStartable
                            ? () {
                                if (isPredefined || AppOverviewPage.customAppsAllowed) {
                                  FlutterUI.of(context).startApp(app: app);
                                } else {
                                  _showForbiddenAppStart(context);
                                }
                              }
                            : null,
                        onLongPress: !AppOverviewPage.isAppHidden(isPredefined, app)
                            ? () => _openAppEditor(
                                  context,
                                  editConfig: AppOverviewPage.useUserSettings(
                                    AppOverviewPage.isPredefinedLocked,
                                    isPredefined,
                                    app,
                                  )
                                      ? app
                                      : predefinedApp,
                                )
                            : null,
                      );
                    } else if (showAddOnFront) {
                      return AppItem(
                        appTitle: "Add",
                        icon: Icons.add,
                        onTap: AppOverviewPage.customAppsAllowed ? () => _showAddApp(context) : null,
                      );
                    }
                    return null;
                  },
                ),
              ),
            ),
          ],
        );
      }
    }
    return child;
  }

  /// Returns either the last started app or the default app if they are not locked or hidden.
  ServerConfig? _getCurrentEditableConfig() {
    String? appName = ConfigController().lastApp.value ?? ConfigController().defaultApp.value;
    if (appName != null) {
      var config = apps?.firstWhereOrNull((element) => element.appName == appName);
      if (!(config?.locked ?? false) && !(config?.parametersHidden ?? false)) {
        return config;
      }
    }
    return null;
  }

  Material _buildMenuButton(BuildContext context, bool showAddOnFront) {
    return Material(
      borderRadius: BorderRadius.circular(25),
      child: Ink(
        decoration: const ShapeDecoration(shape: CircleBorder()),
        child: showAddOnFront
            ? IconButton(
                color: Theme.of(context).colorScheme.primary,
                style: IconButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => IUiService().routeToSettings(),
                icon: const FaIcon(FontAwesomeIcons.gear),
                tooltip: FlutterUI.translate("Settings"),
              )
            : ListTileTheme.merge(
                iconColor: Theme.of(context).colorScheme.primary,
                child: PopupMenuButton(
                  icon: FaIcon(
                    FontAwesomeIcons.ellipsisVertical,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onSelected: (selection) {
                    switch (selection) {
                      case 0:
                        _showAddApp(context);
                        break;
                      case 1:
                        _showClearDialog(context);
                        break;
                      case 2:
                        IUiService().routeToSettings();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    if (AppOverviewPage.customAppsAllowed)
                      PopupMenuItem(
                        value: 0,
                        child: ListTile(
                          leading: const Icon(Icons.add),
                          title: Text(FlutterUI.translate("Add App")),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    if (AppOverviewPage.customAppsAllowed || containsCustomApps)
                      PopupMenuItem(
                        value: 1,
                        child: ListTile(
                          leading: const Icon(Icons.delete),
                          title: Text(FlutterUI.translate("Clear Apps")),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    PopupMenuItem(
                      value: 2,
                      child: ListTile(
                        leading: const FaIcon(FontAwesomeIcons.gear),
                        title: Text(FlutterUI.translate("Settings")),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _openQRScanner(BuildContext context) {
    AppOverviewPage.openQRScanner(
      context,
      allowMultiScan: true,
      callback: (config) async {
        var scaffoldMessenger = ScaffoldMessenger.of(context);
        bool skippedLockedApp = false;

        if (config.apps != null) {
          for (var app in config.apps!) {
            ServerConfig? localConfig = ConfigController().getPredefinedApp(app.appName);
            if (!(localConfig?.locked ?? false)) {
              await FlutterUI.removeApp(app.appName!);
              await FlutterUI.updateApp(app);
            } else {
              skippedLockedApp = true;
              FlutterUI.log.d("Skipping locked app '${app.appName} from QR Code");
            }
          }
        }

        if (skippedLockedApp) {
          scaffoldMessenger.showSnackBar(SnackBar(
            content: Text(FlutterUI.translate("QR Code contained an already existing app.")),
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
    ).then((value) => _refreshApps());
  }

  void _openAppEditor(BuildContext context, {ServerConfig? editConfig}) {
    bool isPredefined = ConfigController().getPredefinedApp(editConfig?.appName) != null;
    IUiService().openDialog(
      context: context,
      pBuilder: (context) => AppEditDialog(
          config: editConfig,
          predefined: isPredefined,
          locked: AppOverviewPage.isAppLocked(isPredefined, editConfig),
          onSubmit: (app) => _updateApp(context, app),
          onCancel: () {
            Navigator.pop(context);
          },
          onDelete: () async {
            Navigator.pop(context);
            await FlutterUI.removeApp(editConfig!.appName!);
            _refreshApps();
          }),
    );
  }

  /// Returns if the update was successful.
  Future<bool> _updateApp(BuildContext context, ServerConfig app) async {
    ServerConfig localConfig = await ConfigController().getApp(app.appName);
    if (!(localConfig.locked ?? false)) {
      if (mounted) {
        Navigator.pop(context);
      }
      await FlutterUI.updateApp(app);
      _refreshApps();
      return true;
    } else if (mounted) {
      await IUiService().openDialog(
        context: context,
        pBuilder: (context) => AlertDialog(
          title: Text(FlutterUI.translate("Duplicated app name")),
          content: Text(FlutterUI.translate("You cannot use the same app name as an already existing app.")),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(FlutterUI.translate("OK")),
            ),
          ],
        ),
        pIsDismissible: true,
      );
    }
    return false;
  }

  Future<void> _showAddApp(BuildContext context) async {
    int? selection = await showDialog(
      // barrierColor: Colors.transparent,
      context: context,
      builder: (context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          title: Text(
            FlutterUI.translate("Add App"),
            textAlign: TextAlign.center,
          ),
          // contentPadding: const EdgeInsets.all(16.0),
          content: ConstrainedBox(
            constraints: const BoxConstraints.tightFor(height: 150),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints.tightFor(width: 150),
                    child: SelectItem(
                      title: FlutterUI.translate("QR Code"),
                      icon: FontAwesomeIcons.qrcode,
                      onTap: () => Navigator.pop(context, 1),
                    ),
                  ),
                ),
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints.tightFor(width: 150),
                    child: SelectItem(
                      title: FlutterUI.translate("Manual"),
                      icon: FontAwesomeIcons.penToSquare,
                      onTap: () => Navigator.pop(context, 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (mounted && selection != null) {
      switch (selection) {
        case 1:
          _openQRScanner(context);
          break;
        case 2:
          _openAppEditor(context);
          break;
      }
    }
  }

  Future<void> _showClearDialog(BuildContext context) async {
    bool? shouldClear = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(FlutterUI.translate("Remove all apps")),
          content: Text(FlutterUI.translate("Are you sure you want to remove all saved apps?")),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(FlutterUI.translate("No")),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: Text(FlutterUI.translate("Yes")),
            ),
          ],
        );
      },
    );
    if (shouldClear ?? false) {
      await FlutterUI.removeAllApps();
      _refreshApps();
    }
  }

  Future<void> _showForbiddenAppStart(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(FlutterUI.translate("Start not allowed")),
          content: Text(FlutterUI.translate("Your current application is configured to not allow custom apps.")),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(FlutterUI.translate("OK")),
            ),
          ],
        );
      },
    );
  }
}
