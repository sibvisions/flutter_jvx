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

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../config/qr_config.dart';
import '../../config/server_config.dart';
import '../../flutter_ui.dart';
import '../../service/apps/app.dart';
import '../../service/apps/i_app_service.dart';
import '../../service/config/i_config_service.dart';
import '../../service/ui/i_ui_service.dart';
import '../../util/image/image_loader.dart';
import '../../util/jvx_colors.dart';
import '../../util/widgets/jvx_scanner.dart';
import '../camera/qr_parser.dart';
import 'app_change_urls_dialog.dart';
import 'app_edit_dialog.dart';
import 'app_item.dart';
import 'select_item.dart';
import 'single_app_view.dart';

class AppOverviewPage extends StatefulWidget {
  static String get appsOrAppText => FlutterUI.translate(IConfigService().isSingleAppMode() ? "App" : "Apps");

  const AppOverviewPage({super.key});

  static const IconData appsIcon = Icons.window;

  static ImageProvider? getAppIcon(App? app) {
    if (app == null) return null;
    String? styleIcon = app.applicationStyle?["icon"];
    return ((app.icon != null && app.baseUrl != null) || styleIcon != null
        ? ImageLoader.getImageProvider(styleIcon ?? app.icon!, app: app)
        : null);
  }

  static Future<void> openQRScanner(
    BuildContext context, {
    required Future<void> Function(QRConfig config) callback,
    bool allowMultiScan = false,
  }) {
    return IUiService().openDialog(
      context: context,
      pBuilder: (context) => JVxScanner(
        allowMultiScan: allowMultiScan,
        title: "QR Scanner",
        formats: const [BarcodeFormat.qrCode],
        callback: (barcodes) async {
          var messengerState = ScaffoldMessenger.of(context);
          for (var barcode in barcodes) {
            FlutterUI.logUI.d("Parsing scanned qr code:\n\n${barcode.rawValue}");
            try {
              final QRConfig config = QRParser.parse(barcode.rawValue!);
              await callback.call(config);
            } catch (e, stack) {
              FlutterUI.logUI.w("Error parsing QR Code", error: e, stackTrace: stack);
              if (barcodes.length == 1) {
                messengerState.showSnackBar(SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text(
                    e is FormatException
                        ? "${FlutterUI.translateLocal("Invalid QR Code")}${e.message.isNotEmpty ? ": ${FlutterUI.translateLocal(e.message)}" : ""}"
                        : FlutterUI.translateLocal("Failed to parse QR Code"),
                  ),
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
        title: Text(FlutterUI.translateLocal("Invalid URL")),
        content: Text("${FlutterUI.translateLocal("URL is invalid")}:\n${e.toString()}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(FlutterUI.translateLocal("OK")),
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
        title: Text(FlutterUI.translateLocal("Missing required fields")),
        content: Text(FlutterUI.translateLocal("You have to provide an app name and URL to add an app.")),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(FlutterUI.translateLocal("OK")),
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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshApps();
  }

  Future<void> _refreshApps() async {
    try {
      await IAppService().refreshStoredApps();
      apps = [...IAppService().getApps().sortedBy<String>((app) => (app.effectiveTitle ?? "").toLowerCase())];
      currentConfig = _getSingleConfig();
      setState(() {});
    } catch (e, stack) {
      FlutterUI.createErrorHandler("Failed to init app list").call(e, stack);
    }
  }

  bool get containsCustomApps => (apps?.where((app) => !app.predefined).isNotEmpty ?? false);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: IConfigService().singleAppMode,
      builder: (context, value, child) {
        return PageStorage(
          bucket: FlutterUI.of(context).globalStorageBucket,
          child: Theme(
            data: JVxColors.applyJVxTheme(ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                brightness: Theme.of(context).colorScheme.brightness,
                seedColor: Colors.blue,
              ),
            )),
            child: Scaffold(
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
                                          FlutterUI.translateLocal(
                                              IConfigService().isSingleAppMode() ? "Application" : "Applications"),
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
                                  IConfigService().isSingleAppMode() || showAddOnFront,
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
              floatingActionButton: IConfigService().isSingleAppMode()
                  ? FloatingActionButton(
                      tooltip: FlutterUI.translateLocal("Scan QR Code"),
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppList(BuildContext context, AsyncSnapshot snapshot, bool showAddOnFront) {
    Widget child;
    if (snapshot.hasError) {
      child = const FaIcon(FontAwesomeIcons.circleExclamation);
    } else {
      if (IConfigService().isSingleAppMode()) {
        child = SingleAppView(
          config: currentConfig,
          onStart: (config) async {
            App? editedApp = await _updateApp(
              context,
              config.merge(const ServerConfig(isDefault: true)),
            );
            if (editedApp != null && mounted) {
              unawaited(IAppService().startApp(appId: editedApp.id, autostart: false));
            }
          },
        );
      } else {
        child = CustomScrollView(
          key: const PageStorageKey("OverviewList"),
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
                        offline: app.offline,
                        predefined: app.predefined,
                        onTap: app.isStartable
                            ? () {
                                if (app.predefined || App.customAppsAllowed) {
                                  IAppService().startApp(appId: app.id, autostart: false);
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

  /// Returns either the last started app, the default app or the first app that is not hidden.
  App? _getSingleConfig() {
    Iterable<String?> appIds = [
      IConfigService().lastApp.value,
      IConfigService().defaultApp.value,
    ].whereNotNull();

    return apps?.firstWhereOrNull((app) => appIds.contains(app.id) && !app.parametersHidden);
  }

  Material _buildMenuButton(BuildContext context, bool showAddOnFront) {
    return Material(
      borderRadius: BorderRadius.circular(25),
      child: Ink(
        decoration: const ShapeDecoration(shape: CircleBorder()),
        child: showAddOnFront
            ? IconButton(
                tooltip: FlutterUI.translateLocal("Settings"),
                color: Theme.of(context).colorScheme.primary,
                style: IconButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => IUiService().routeToSettings(),
                icon: const FaIcon(FontAwesomeIcons.gear),
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
                          title: Text(FlutterUI.translateLocal("Add app")),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    if (apps?.isNotEmpty ?? false)
                      PopupMenuItem(
                        value: 1,
                        child: ListTile(
                          leading: Icon(containsCustomApps ? Icons.delete : Icons.history),
                          title: Text(FlutterUI.translateLocal("${containsCustomApps ? "Remove" : "Reset"} apps")),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    PopupMenuItem(
                      value: 2,
                      child: ListTile(
                        leading: const FaIcon(FontAwesomeIcons.gear),
                        title: Text(FlutterUI.translateLocal("Settings")),
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
        if (config.apps != null) {
          for (var serverConfig in config.apps!) {
            var app = await App.getApp(App.computeIdFromConfig(serverConfig)!);
            apps?.remove(app);
            await app?.delete();
            app = await App.createAppFromConfig(serverConfig);
          }
        }

        if (config.policy != null) {
          await IConfigService().updatePrivacyPolicy(config.policy);
        }
        unawaited(_refreshApps());
      },
    );
  }

  void _openAppEditor(BuildContext context, {App? editApp}) {
    IUiService().openDialog(
      context: context,
      pBuilder: (context) => AppEditDialog(
        config: editApp,
        predefined: editApp?.predefined ?? false,
        locked: editApp?.locked ?? false,
        onSubmit: (config) => _updateApp(context, config, oldApp: editApp),
        onCancel: () {
          Navigator.pop(context);
        },
        onDelete: () async {
          bool? shouldDelete = await _showDeleteDialog(context, editApp?.predefined ?? false);
          if (!mounted) return;
          if (shouldDelete ?? false) {
            Navigator.pop(context);
            apps?.remove(editApp);
            await editApp!.delete();
            unawaited(_refreshApps());
          }
        },
        onLongDelete: () async {
          bool? shouldDelete = await _showDeleteDataDialog(context);
          if (!mounted) return;
          if (shouldDelete ?? false) {
            Navigator.pop(context);
            await editApp!.deleteData();
            unawaited(_refreshApps());
          }
        },
      ),
    );
  }

  /// Returns whether the update was successful.
  Future<App?> _updateApp(BuildContext context, ServerConfig config, {App? oldApp}) async {
    App? app = oldApp != null ? await App.getApp(oldApp.id) : null;
    assert(oldApp == null || !oldApp.locked, "Locked apps cannot be updated.");

    if (app == null) {
      app = await App.createAppFromConfig(config);
    } else {
      String oldHost = app.baseUrl?.host ?? "";
      bool changedUrl = config.baseUrl != null && oldHost != config.baseUrl!.host;

      // If this is not an predefined app and the key parameters changed, change id.
      if (!app.predefined && (app.name != config.appName || app.baseUrl != config.baseUrl)) {
        await app.updateId(App.computeId(config.appName, config.baseUrl.toString(), predefined: false)!);
      }

      await app.updateFromConfig(config);

      if (changedUrl) {
        // All apps with the same host will be asked if they should be updated too.
        final List<App> appsSameHost = IAppService()
            .getApps()
            .where((element) => element.id != app!.id && element.baseUrl != null && element.baseUrl!.host == oldHost)
            .toList();

        if (appsSameHost.isNotEmpty && context.mounted) {
          await showDialog(
            context: context,
            builder: (context) => AppChangeUrlsDialog(
              oldHost: oldHost,
              newHost: app!.baseUrl!.host,
              appsToChange: appsSameHost,
            ),
          );
        }
      }
    }

    if (context.mounted) {
      Navigator.pop(context);
    }

    unawaited(_refreshApps());
    return app;
  }

  Future<void> _showAddApp(BuildContext context) async {
    int? selection = await showDialog(
      // barrierColor: Colors.transparent,
      context: context,
      builder: (context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          title: Text(
            FlutterUI.translateLocal("Add app"),
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
                      title: FlutterUI.translateLocal("QR Code"),
                      icon: FontAwesomeIcons.qrcode,
                      onTap: () => Navigator.pop(context, 1),
                    ),
                  ),
                ),
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints.tightFor(width: 150),
                    child: SelectItem(
                      title: FlutterUI.translateLocal("Manual"),
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

  Future<bool?> _showDeleteDialog(BuildContext context, bool predefined) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(FlutterUI.translateLocal("${predefined ? "Reset" : "Delete"} this app?")),
          content:
              Text(FlutterUI.translateLocal("Are you sure you want to ${predefined ? "reset" : "delete"} this app?")),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(FlutterUI.translateLocal("No")),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              onPressed: () => Navigator.pop(context, true),
              child: Text(FlutterUI.translateLocal("Yes")),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showDeleteDataDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(FlutterUI.translateLocal("Delete app data?")),
          content: Text(FlutterUI.translateLocal("Are you sure you want to delete the data of this app?")),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(FlutterUI.translateLocal("No")),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              onPressed: () => Navigator.pop(context, true),
              child: Text(FlutterUI.translateLocal("Yes")),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showClearDialog(BuildContext context) async {
    bool? shouldClear = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(FlutterUI.translateLocal("${containsCustomApps ? "Remove" : "Reset"} all apps")),
          content: Text(
            FlutterUI.translateLocal("Are you sure you want to ${containsCustomApps ? "remove" : "reset"} all apps?"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(FlutterUI.translateLocal("No")),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              onPressed: () => Navigator.pop(context, true),
              child: Text(FlutterUI.translateLocal("Yes")),
            ),
          ],
        );
      },
    );
    if (shouldClear ?? false) {
      await IAppService().removeAllApps();
      unawaited(_refreshApps());
    }
  }

  Future<void> _showForbiddenAppStart(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(FlutterUI.translateLocal("Start not allowed")),
          content: Text(
              FlutterUI.translateLocal("Your current application was configured without support for custom apps.")),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(FlutterUI.translateLocal("OK")),
            ),
          ],
        );
      },
    );
  }
}
