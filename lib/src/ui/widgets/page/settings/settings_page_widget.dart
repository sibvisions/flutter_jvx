import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterclient/src/util/app/version/app_version.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../../../models/state/app_state.dart';
import '../../../../models/state/routes/export_routes.dart';
import '../../../../services/local/shared_preferences/shared_preferences_manager.dart';
import '../../../../util/app/get_image_string.dart';
import '../../../../util/color/color_extension.dart';
import '../../../../util/translation/app_localizations.dart';
import '../../../util/restart_widget.dart';
import 'language_picker.dart';
import 'picture_size_picker.dart';
import 'qr_code_view_widget.dart';
import 'qr_floating_action_button.dart';
import 'settings_bottom_navigation_bar.dart';
import 'settings_dialogs.dart';
import 'settings_version_card.dart';

class SettingsPageWidget extends StatefulWidget {
  final AppState appState;
  final SharedPreferencesManager manager;
  final bool canPop;
  final bool hasError;

  const SettingsPageWidget(
      {Key? key,
      required this.appState,
      required this.manager,
      this.canPop = true,
      this.hasError = false})
      : super(key: key);

  @override
  _SettingsPageWidgetState createState() => _SettingsPageWidgetState();
}

class _SettingsPageWidgetState extends State<SettingsPageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  String? baseUrl, appName, language, username, password;

  int? picSize = 320;

  String version = '', commit = '', buildNumber = '', buildDate = '';

  bool isDialogOpen = false;

  String get versionText {
    String v = 'AppVersion v$version Build $buildNumber';

    if (widget.appState.applicationMetaData != null &&
        widget.appState.applicationMetaData!.version.isNotEmpty) {
      v += '\nServer v${widget.appState.applicationMetaData!.version}';
    }

    return v;
  }

  String get pictureSizeText {
    switch (picSize) {
      case 320:
        return 'Small';
      case 640:
        return 'Medium';
      case 1024:
        return 'Big';
      default:
        return 'Small';
    }
  }

  void _loadVersion() async {
    AppVersion? appVersion;

    if (widget.appState.appVersion != null) {
      appVersion = widget.appState.appVersion;
    } else {
      appVersion = await AppVersion.loadFile(
          package: widget.appState.appConfig!.package);
    }

    if (mounted && appVersion != null) {
      setState(() {
        version = appVersion!.buildName;
        buildNumber = appVersion.buildNumber;
        commit = appVersion.commit;
        buildDate = appVersion.date;
      });
    }
  }

  void _initAppData() {
    baseUrl = widget.appState.serverConfig?.baseUrl;
    appName = widget.appState.serverConfig?.appName;
    language = widget.appState.language?.language;
    picSize = widget.appState.picSize;
  }

  void _showLanguageDialog() {
    if (mounted) {
      setState(() => isDialogOpen = true);

      List<String> langsToChoose = <String>[];

      for (final lang in widget
          .appState.translationConfig.possibleTranslations.keys
          .toList()) {
        if (lang.contains('.json')) {
          String? toAdd = lang.split('.json')[0];
          if (lang.contains('_'))
            toAdd = toAdd.split('_')[1];
          else
            toAdd = 'en';

          if (toAdd.isNotEmpty) {
            langsToChoose.add(toAdd);
          }
        }
      }

      showLanguagePicker(context, scaffoldKey, langsToChoose,
          (String? newLanguage) {
        setState(() {
          if (newLanguage != null && newLanguage.isNotEmpty) {
            language = newLanguage;
          }

          isDialogOpen = false;
        });
      });
    }
  }

  void _showPictureSizeDialog() {
    if (mounted) {
      setState(() => isDialogOpen = true);

      showPictureSizePicker(context, scaffoldKey, (int? newSize) {
        setState(() {
          if (newSize != null) {
            picSize = newSize;
          }

          isDialogOpen = false;
        });
      });
    }
  }

  Map<String, dynamic> _getPropertiesFromQR(String data) {
    Map<String, dynamic> properties = <String, dynamic>{};

    if (data.isNotEmpty && data != '-1') {
      try {
        properties = json.decode(data);
      } catch (e) {
        List<String?> result = data.split('\n');

        if (data.contains('Application') && _checkQRString(result[0]))
          properties['APPNAME'] =
              result[0]?.substring(result[0]!.indexOf(': ') + 2);

        if (data.contains('URL') && _checkQRString(result[1]))
          properties['URL'] =
              result[1]?.substring(result[1]!.indexOf(': ') + 2);

        if (data.contains('USER') &&
            result.length >= 3 &&
            _checkQRString(result[2]))
          properties['USER'] =
              result[2]?.substring(result[2]!.indexOf(': ') + 2);

        if (data.contains('PWD') &&
            result.length >= 4 &&
            _checkQRString(result[3]))
          properties['PWD'] =
              result[3]?.substring(result[3]!.indexOf(': ') + 2);
      }
    }

    return properties;
  }

  bool _checkQRString(String? qrString) {
    return (qrString != null && qrString.isNotEmpty && qrString.contains(': '));
  }

  Future<void> scanBarcode() async {
    final Barcode? result = await Navigator.of(context)
        .push(DefaultPageRoute(builder: (_) => QrCodeViewWidget()));

    if (result != null) {
      Map<String, dynamic> _properties = _getPropertiesFromQR(result.code);

      setState(() {
        if (_properties['APPNAME'] != null) {
          appName = _properties['APPNAME'];
        }

        if (_properties['URL'] != null) {
          baseUrl = _properties['URL'];
        }

        if (_properties['USER'] != null && _properties['PWD'] != null) {
          username = _properties['USER'];
          password = _properties['PWD'];
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _initAppData();

    _loadVersion();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.appState.widgetConfig.welcomeWidget != null) {
      return widget.appState.widgetConfig.welcomeWidget!;
    }

    return WillPopScope(
      onWillPop: () async => widget.canPop,
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.grey.shade300,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: !kIsWeb && !isDialogOpen
            ? QrFloatingActionButton(
                icon: FaIcon(
                  FontAwesomeIcons.qrcode,
                  color: Theme.of(context).primaryColor.textColor(),
                ),
                onPressed: () async => await scanBarcode(),
              )
            : null,
        appBar: AppBar(
          automaticallyImplyLeading: widget.canPop,
          iconTheme:
              IconThemeData(color: Theme.of(context).primaryColor.textColor()),
          title: Text(
            AppLocalizations.of(context)!.text('Settings'),
            style: TextStyle(color: Theme.of(context).primaryColor.textColor()),
          ),
        ),
        bottomNavigationBar: !isDialogOpen
            ? SettingsBottomAppBar(
                canPop: widget.canPop,
                onSave: () {
                  if (appName != null &&
                      appName!.isNotEmpty &&
                      baseUrl != null &&
                      baseUrl!.isNotEmpty) {
                    if (appName != widget.appState.serverConfig?.appName ||
                        baseUrl != widget.appState.serverConfig?.baseUrl) {
                      widget.manager
                          .setSyncLoginData(username: null, password: null);
                    }

                    widget.manager.appName = appName;
                    widget.manager.baseUrl = baseUrl;
                    if (widget.manager.language != language) {
                      widget.manager.language = language;
                    }
                    widget.manager.picSize = picSize;

                    widget.appState.serverConfig!.username = username;
                    widget.appState.serverConfig!.password = password;

                    widget.manager.loadConfig = false;

                    RestartWidget.restart(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please fill out all fields!')));
                  }
                },
              )
            : null,
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20, left: 16),
                child: Text(
                  AppLocalizations.of(context)!.text('Application Settings'),
                  style: TextStyle(
                      color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                ),
              ),
              Card(
                margin: const EdgeInsets.only(left: 8, right: 8),
                color: Colors.white,
                elevation: 2.0,
                child: Column(
                  children: [
                    ListTile(
                      leading: FaIcon(
                        FontAwesomeIcons.server,
                        color: Theme.of(context).primaryColor,
                      ),
                      trailing: FaIcon(FontAwesomeIcons.arrowRight),
                      title:
                          Text(AppLocalizations.of(context)!.text('App name')),
                      subtitle: Text(appName ?? ''),
                      onTap: () async {
                        if (widget.appState.serverConfig != null &&
                            (widget.appState.serverConfig!.isProd ||
                                widget.appState.serverConfig!.isPreview)) {
                          return;
                        }

                        String? newAppName = await showDialog(
                            context: context,
                            builder: (context) {
                              return AppNameDialog(
                                appName: appName ?? '',
                              );
                            });

                        if (newAppName != null && newAppName.isNotEmpty) {
                          setState(() {
                            appName = newAppName;
                          });
                        }
                      },
                    ),
                    ListTile(
                      leading: FaIcon(
                        FontAwesomeIcons.keyboard,
                        color: Theme.of(context).primaryColor,
                      ),
                      trailing: FaIcon(FontAwesomeIcons.arrowRight),
                      title:
                          Text(AppLocalizations.of(context)!.text('Base Url')),
                      subtitle: Text(baseUrl ?? ''),
                      onTap: () async {
                        if (widget.appState.serverConfig != null &&
                            (widget.appState.serverConfig!.isProd ||
                                widget.appState.serverConfig!.isPreview)) {
                          return;
                        }

                        String? newBaseUrl = await showDialog<String>(
                            context: context,
                            builder: (context) {
                              return BaseUrlDialog(
                                baseUrl: baseUrl ?? '',
                              );
                            });

                        if (newBaseUrl != null && newBaseUrl.isNotEmpty) {
                          setState(() {
                            baseUrl = newBaseUrl;
                          });
                        }
                      },
                    ),
                    if (widget.canPop && !widget.hasError)
                      ListTile(
                        leading: FaIcon(
                          FontAwesomeIcons.language,
                          color: Theme.of(context).primaryColor,
                        ),
                        title: Text(
                            AppLocalizations.of(context)!.text('Language')),
                        trailing: FaIcon(FontAwesomeIcons.arrowRight),
                        subtitle: Text(language ?? ''),
                        onTap: () {
                          _showLanguageDialog();
                        },
                      ),
                    ListTile(
                      leading: FaIcon(
                        FontAwesomeIcons.image,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: Text(pictureSizeText),
                      subtitle: Text('$picSize px'),
                      trailing: FaIcon(FontAwesomeIcons.arrowRight),
                      onTap: () {
                        _showPictureSizeDialog();
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20, left: 16),
                child: Text(
                  AppLocalizations.of(context)!.text('Version Info'),
                  style: TextStyle(
                      color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                ),
              ),
              if (version.isNotEmpty)
                SettingsVersionCard(
                  versionString: versionText,
                  commit: commit,
                  buildDate: buildDate,
                )
              else
                Center(child: CircularProgressIndicator.adaptive())
            ],
          ),
        ),
      ),
    );
  }
}
