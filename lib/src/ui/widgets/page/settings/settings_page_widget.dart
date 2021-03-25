import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterclient/src/ui/widgets/page/settings/picture_size_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../../../models/state/app_state.dart';
import '../../../../services/local/shared_preferences/shared_preferences_manager.dart';
import '../../../../util/app/get_image_string.dart';
import '../../../../util/color/color_extension.dart';
import '../../../../util/translation/app_localizations.dart';
import '../../../util/restart_widget.dart';
import 'language_picker.dart';
import 'qr_floating_action_button.dart';
import 'settings_bottom_navigation_bar.dart';
import 'settings_dialogs.dart';
import 'settings_version_card.dart';

class SettingsPageWidget extends StatefulWidget {
  final AppState appState;
  final SharedPreferencesManager manager;
  final bool canPop;

  const SettingsPageWidget(
      {Key? key,
      required this.appState,
      required this.manager,
      this.canPop = true})
      : super(key: key);

  @override
  _SettingsPageWidgetState createState() => _SettingsPageWidgetState();
}

class _SettingsPageWidgetState extends State<SettingsPageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  String? baseUrl, appName, language;

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
    Map<String, dynamic> versionMap =
        await rootBundle.loadStructuredData<Map<String, dynamic>>(
            getPackageString(
                widget.appState, 'assets/version/app_version.json'),
            (String toParse) async =>
                Map<String, dynamic>.from(json.decode(toParse)));

    if (mounted) {
      setState(() {
        if (versionMap.containsKey('version') &&
            versionMap.containsKey('commit') &&
            versionMap.containsKey('date')) {
          if (versionMap['version'] != null) {
            List<String> splitted = versionMap['version'].split('+');
            version = splitted[0];
            buildNumber = splitted[1];
          }
          commit = versionMap['commit'];

          DateTime date =
              DateTime.fromMillisecondsSinceEpoch(versionMap['date']);

          buildDate = DateFormat('dd.MM.yyyy').format(date);
        }
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

  @override
  void initState() {
    super.initState();

    _initAppData();

    _loadVersion();
  }

  @override
  Widget build(BuildContext context) {
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
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('QR Code scanning will be enabled soon!')));
                },
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
                    widget.manager.appName = appName;
                    widget.manager.baseUrl = baseUrl;
                    if (widget.manager.language != language) {
                      widget.manager.language = language;
                    }
                    widget.manager.picSize = picSize;

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
                    if (widget.canPop)
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
