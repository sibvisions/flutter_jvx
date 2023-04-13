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

import '../../config/qr_config.dart';
import '../../config/server_config.dart';
import '../../flutter_ui.dart';
import '../../service/apps/app.dart';
import '../../service/apps/app_service.dart';
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

  static ImageProvider? getAppIcon(App? app) {
    if (app == null) return null;
    String? styleIcon = app.applicationStyle?["icon"];
    return ((app.icon != null && app.baseUrl != null) || styleIcon != null
        ? ImageLoader.getImageProvider(
            styleIcon ?? app.icon!,
            app: app,
            baseUrl: app.baseUrl,
          )
        : null);
  }

  static Future<void> openQRScanner(
    BuildContext context, {
    required Future<void> Function(QRConfig config) callback,
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
              final QRConfig config = QRParser.parse(barcode.rawValue!);
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
        content: Text(FlutterUI.translate("You have to provide an app name and URL to add an app.")),
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

  @override
  State<AppOverviewPage> createState() => _AppOverviewPageState();
}

class _AppOverviewPageState extends State<AppOverviewPage> {
  late final WidgetBuilder? backgroundBuilder;
  List<App>? apps;
  Future<void>? future;

  App? currentConfig;

  @override
  void initState() {
    super.initState();
    backgroundBuilder = FlutterUI.of(context).widget.backgroundBuilder;
    _refreshApps();
  }

  void _refreshApps() {
    setState(() {
      future = () async {
        var retrievedApps = App.getAppsByIDs(AppService().getAppIds());
        apps = [...retrievedApps];
        currentConfig = _getCurrentEditableConfig();
      }()
          .catchError(FlutterUI.createErrorHandler("Failed to init app list"));
    });
  }

  bool get containsCustomApps => (apps?.where((app) => !app.predefined).isNotEmpty ?? false);

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
                            fit: StackFit.expand,
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
                                              AppService().isSingleAppMode() ? "Application" : "Applications"),
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
                                  AppService().isSingleAppMode() || showAddOnFront,
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
              floatingActionButton: AppService().isSingleAppMode()
                  ? FloatingActionButton(
                      tooltip: FlutterUI.translate("Scan QR Code"),
                      onPressed: () => AppOverviewPage.openQRScanner(
                        context,
                        callback: (config) async {
                          var serverConfig = config.apps?.firstOrNull;
                          if (serverConfig != null) {
                            currentConfig = await App.createAppFromConfig(serverConfig);
                            setState(() {});
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
      if (AppService().isSingleAppMode()) {
        child = SingleAppView(
          config: currentConfig,
          onStart: (config) async {
            App? editedApp = await _updateApp(
              context,
              config.merge(const ServerConfig(isDefault: true)),
            );
            if (editedApp != null && mounted) {
              FlutterUI.of(this.context).startApp(appId: editedApp.id, autostart: false);
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
                      App app = apps![index];
                      return AppItem(
                        key: ObjectKey(app),
                        enabled: (app.predefined || App.customAppsAllowed) && app.isStartable,
                        appTitle: app.effectiveTitle ?? "-",
                        image: AppOverviewPage.getAppIcon(app),
                        isDefault: app.isDefault,
                        locked: app.locked,
                        hidden: app.parametersHidden,
                        predefined: app.predefined,
                        onTap: app.isStartable
                            ? () {
                                if (app.predefined || App.customAppsAllowed) {
                                  FlutterUI.of(context).startApp(appId: app.id, autostart: false);
                                } else {
                                  _showForbiddenAppStart(context);
                                }
                              }
                            : null,
                        onLongPress: !app.parametersHidden
                            ? () => _openAppEditor(
                                  context,
                                  editApp: app,
                                )
                            : null,
                      );
                    } else if (showAddOnFront) {
                      return AppItem(
                        appTitle: "Add",
                        icon: Icons.add,
                        onTap: App.customAppsAllowed ? () => _showAddApp(context) : null,
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
  App? _getCurrentEditableConfig() {
    String? appId = ConfigController().lastApp.value ?? ConfigController().defaultApp.value;
    if (appId != null) {
      var config = apps?.firstWhereOrNull((element) => element.id == appId);
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
                    if (App.customAppsAllowed)
                      PopupMenuItem(
                        value: 0,
                        child: ListTile(
                          leading: const Icon(Icons.add),
                          title: Text(FlutterUI.translate("Add app")),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    if (App.customAppsAllowed || containsCustomApps)
                      PopupMenuItem(
                        value: 1,
                        child: ListTile(
                          leading: const Icon(Icons.delete),
                          title: Text(FlutterUI.translate("Remove apps")),
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

  void _scanQR(BuildContext context) {
    AppOverviewPage.openQRScanner(
      context,
      allowMultiScan: true,
      callback: (config) async {
        var scaffoldMessenger = ScaffoldMessenger.of(context);
        bool skippedLockedApp = false;

        if (config.apps != null) {
          for (var serverConfig in config.apps!) {
            var app = App.getApp(App.computeIdFromConfig(serverConfig)!);
            if (!(app?.locked ?? false)) {
              apps?.remove(app);
              await app?.delete();
              app = await App.createAppFromConfig(serverConfig);
            } else {
              skippedLockedApp = true;
              FlutterUI.log.d("Skipping locked app '${serverConfig.appName} from QR Code");
            }
          }
        }

        if (config.policy != null) {
          await ConfigController().updatePrivacyPolicy(config.policy);
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

  void _openAppEditor(BuildContext context, {App? editApp}) {
    IUiService().openDialog(
      context: context,
      pBuilder: (context) => AppEditDialog(
          config: editApp,
          predefined: editApp?.predefined ?? false,
          locked: editApp?.locked ?? false,
          onSubmit: (config) => _updateApp(context, config, editApp: editApp),
          onCancel: () {
            Navigator.pop(context);
          },
          onDelete: () async {
            Navigator.pop(context);
            apps?.remove(editApp);
            await editApp!.delete();
            _refreshApps();
          }),
    );
  }

  /// Returns if the update was successful.
  Future<App?> _updateApp(BuildContext context, ServerConfig config, {App? editApp}) async {
    App? app = editApp != null ? App.getApp(editApp.id) : null;
    if (!(app?.locked ?? false)) {
      app ??= App.createApp(name: config.appName!, baseUrl: config.baseUrl!);

      // If this is not an predefined app and the key parameters changed, change id.
      if (!app.predefined && (app.name != config.appName || app.baseUrl != config.baseUrl)) {
        await app.updateId(App.computeId(config.appName, config.baseUrl.toString(), predefined: false)!);
      }
      await app.updateFromConfig(config);

      if (mounted) {
        Navigator.pop(context);
      }
      _refreshApps();
      return app;
    } else if (mounted) {
      await IUiService().openDialog(
        context: context,
        pBuilder: (context) => AlertDialog(
          title: Text(FlutterUI.translate("Duplicated app")),
          content: Text(FlutterUI.translate("You cannot use the same app name and URL as an provided app.")),
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
    return null;
  }

  Future<void> _showAddApp(BuildContext context) async {
    int? selection = await showDialog(
      // barrierColor: Colors.transparent,
      context: context,
      builder: (context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          title: Text(
            FlutterUI.translate("Add app"),
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
          _scanQR(context);
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
          content: Text(FlutterUI.translate("Are you sure you want to remove all apps?")),
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
      await AppService().removeAllApps();
      _refreshApps();
    }
  }

  Future<void> _showForbiddenAppStart(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(FlutterUI.translate("Start not allowed")),
          content:
              Text(FlutterUI.translate("Your current application was configured without support for custom apps.")),
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
