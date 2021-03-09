import 'dart:convert';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../../injection_container.dart';
import '../../models/app/app_state.dart';
import '../../services/local/shared_preferences_manager.dart';
import '../../utils/theme/theme_manager.dart';
import '../../utils/translation/app_localizations.dart';
import '../widgets/common/common_scaffold.dart';
import '../widgets/dialogs/dialogs.dart';
import '../widgets/util/restart_widget.dart';

class SettingsPage extends StatefulWidget {
  static const String route = '/settings';
  final AppState appState;
  final SharedPreferencesManager manager;
  final bool warmWelcome;

  SettingsPage({
    Key key,
    @required this.appState,
    @required this.manager,
    @required this.warmWelcome,
  }) : super(key: key);

  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final scaffoldState = GlobalKey<ScaffoldState>();
  String appName,
      baseUrl,
      language,
      version,
      buildNumber,
      buildDate,
      commitHash;
  String toSaveUsername;
  String toSavePwd;
  List<PickerItem<int>> imageSizeItems;
  bool isDialogOpen = false;

  String selectedLanguage;

  String get versionText {
    String v = 'App v$version Build $buildNumber';
    if (widget.appState.appVersion != null &&
        widget.appState.appVersion.isNotEmpty)
      v += '\nServer v${widget.appState.appVersion}';

    return v;
  }

  String get imageSizeTitle {
    if (this.imageSizeItems == null) {
      this.imageSizeItems = [
        PickerItem<int>(
            text: Text(AppLocalizations.of(context).text('Small (320 px)')),
            value: 320),
        PickerItem<int>(
            text: Text(AppLocalizations.of(context).text('Medium (640 px)')),
            value: 640),
        PickerItem<int>(
            text: Text(AppLocalizations.of(context).text('Big (1024 px)')),
            value: 1024),
      ];
    }

    PickerItem<int> item = this.imageSizeItems.firstWhere(
        (element) => element.value == widget.appState.picSize,
        orElse: () => null);
    if (item != null) return (item.text as Text).data;

    widget.appState.picSize = this.imageSizeItems[0].value;
    return (this.imageSizeItems[0].text as Text).data;
  }

  int get imageSizeIndex {
    return this
        .imageSizeItems
        .indexWhere((element) => element.value == widget.appState.picSize);
  }

  @override
  void initState() {
    super.initState();

    loadVersion();
  }

  Widget settingsBuilder() {
    return SingleChildScrollView(
      child: Theme(
        data: sl<ThemeManager>().themeData,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                AppLocalizations.of(context).text('Application Settings'),
                style: TextStyle(
                    color: Colors.grey.shade700, fontWeight: FontWeight.bold),
              ),
            ),
            Card(
              color: Colors.white,
              elevation: 2.0,
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: FaIcon(
                      FontAwesomeIcons.server,
                      color: sl<ThemeManager>().themeData.primaryColor,
                    ),
                    title: Text(AppLocalizations.of(context).text('App name')),
                    trailing: FaIcon(FontAwesomeIcons.arrowRight),
                    subtitle: Text(widget.appState.appName != null
                        ? widget.appState.appName
                        : ''),
                    onTap: () {
                      if (!widget.appState.isOffline)
                        showTextInputDialog(
                            context,
                            AppLocalizations.of(context).text('App name'),
                            AppLocalizations.of(context).text('App name'),
                            AppLocalizations.of(context)
                                .text('Enter new App Name'),
                            widget.appState.appName, (String value) {
                          if (value == null)
                            this.appName = widget.appState.appName;
                          else {
                            setState(() {
                              this.appName = value;
                              widget.appState.appName = value;
                            });
                          }
                        });
                    },
                  ),
                  ListTile(
                    leading: FaIcon(
                      FontAwesomeIcons.keyboard,
                      color: sl<ThemeManager>().themeData.primaryColor,
                    ),
                    title: Text(AppLocalizations.of(context).text('Base Url')),
                    trailing: FaIcon(FontAwesomeIcons.arrowRight),
                    subtitle: Text(widget.appState.baseUrl != null
                        ? widget.appState.baseUrl
                        : ''),
                    onTap: () {
                      if (!widget.appState.isOffline)
                        showTextInputDialog(
                            context,
                            AppLocalizations.of(context).text('Base Url'),
                            AppLocalizations.of(context).text('Base Url'),
                            'http://enter.baseUrl/services/mobile',
                            widget.appState.baseUrl, (String value) {
                          if (value == null)
                            this.baseUrl = widget.appState.baseUrl;
                          else {
                            if (value.endsWith('/')) {
                              value = value.substring(0, value.length - 1);
                            }

                            setState(() {
                              this.baseUrl = value;
                              widget.appState.baseUrl = value;
                            });
                          }
                        });
                    },
                  ),
                  (widget.warmWelcome != null && !widget.warmWelcome)
                      ? ListTile(
                          leading: FaIcon(
                            FontAwesomeIcons.language,
                            color: sl<ThemeManager>().themeData.primaryColor,
                          ),
                          title: Text(
                              AppLocalizations.of(context).text('Language')),
                          trailing: FaIcon(FontAwesomeIcons.arrowRight),
                          subtitle: Text(widget.appState.language != null
                              ? widget.appState.language
                              : ''),
                          onTap: () {
                            if (!widget.appState.isOffline)
                              showLanguagePicker(context);
                          },
                        )
                      : Container(),
                  ListTile(
                    leading: FaIcon(
                      FontAwesomeIcons.image,
                      color: sl<ThemeManager>().themeData.primaryColor,
                    ),
                    title: Text(this.imageSizeTitle),
                    trailing: FaIcon(FontAwesomeIcons.arrowRight),
                    onTap: () {
                      if (!widget.appState.isOffline)
                        showImageSizePicker(context);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                AppLocalizations.of(context).text('Version info'),
                style: TextStyle(
                    color: Colors.grey.shade700, fontWeight: FontWeight.bold),
              ),
            ),
            Card(
                color: Colors.white,
                elevation: 2.0,
                child: Column(children: <Widget>[
                  ListTile(
                    leading: FaIcon(
                      FontAwesomeIcons.codeBranch,
                    ),
                    title: Text(
                      versionText,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                  ListTile(
                    leading: FaIcon(FontAwesomeIcons.calendar),
                    title: Text(
                      buildDate ?? '',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                  ListTile(
                    leading: FaIcon(FontAwesomeIcons.github),
                    title: Text(
                      commitHash ?? '',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                ]))
          ],
        ),
      ),
    );
  }

  loadVersion() async {
    Map<String, dynamic> buildversion =
        widget.appState.config.appVersion != null
            ? widget.appState.config.appVersion
            : json.decode(await rootBundle.loadString(widget.appState.package
                ? 'packages/jvx_flutterclient/env/app_version.json'
                : 'env/app_version.json'));

    setState(() {
      version = buildversion['version'];
      if (version != null) {
        List<String> splittedVersion = version.split("+");
        if (splittedVersion.length == 2) {
          version = splittedVersion[0];
          buildNumber = splittedVersion[1];
        }
      }
      buildDate = buildversion['build_date'];
      commitHash = buildversion['commit'];
      if (buildDate != null) {
        DateTime date = DateTime.parse(buildDate);
        DateFormat formatter = DateFormat('dd.MM.yyyy');
        if (date != null) buildDate = formatter.format(date);
      }
    });
    print(versionText);
  }

  showImageSizePicker(BuildContext context) {
    List<int> selected;
    if (this.imageSizeIndex >= 0 &&
        this.imageSizeIndex < this.imageSizeItems.length)
      selected = [this.imageSizeIndex];

    setState(() {
      isDialogOpen = true;
    });

    new Picker(
      confirmText: AppLocalizations.of(context).text('Confirm'),
      cancelText: AppLocalizations.of(context).text('Cancel'),
      adapter: PickerDataAdapter(data: this.imageSizeItems),
      selecteds: selected,
      changeToFirst: true,
      textAlign: TextAlign.center,
      columnPadding: const EdgeInsets.all(8.0),
      confirmTextStyle:
          TextStyle(color: sl<ThemeManager>().themeData.primaryColor),
      cancelTextStyle:
          TextStyle(color: sl<ThemeManager>().themeData.primaryColor),
      onConfirm: (Picker picker, List value) {
        setState(() {
          isDialogOpen = false;

          widget.appState.picSize = picker.getSelectedValues()[0];
        });
      },
      onCancel: () => setState(() => isDialogOpen = false),
      onSelect: (picker, index, selecteds) =>
          setState(() => isDialogOpen = false),
    ).show(scaffoldState.currentState);
  }

  showLanguagePicker(BuildContext context) {
    List<String> languages = List<String>.from(
        widget.appState.supportedLocales.map((e) => e.languageCode));

    if (languages != null && languages.isNotEmpty) {
      List<int> selected;
      int selectedIndex = languages
          .indexWhere((element) => element == widget.appState.language ?? 'en');

      if (selectedIndex >= 0 && selectedIndex < languages.length)
        selected = [selectedIndex];

      setState(() {
        isDialogOpen = true;
      });

      new Picker(
        confirmText: AppLocalizations.of(context).text('Confirm'),
        cancelText: AppLocalizations.of(context).text('Cancel'),
        adapter: PickerDataAdapter<String>(pickerdata: languages),
        selecteds: selected,
        changeToFirst: true,
        textAlign: TextAlign.center,
        columnPadding: const EdgeInsets.all(8.0),
        confirmTextStyle:
            TextStyle(color: sl<ThemeManager>().themeData.primaryColor),
        cancelTextStyle:
            TextStyle(color: sl<ThemeManager>().themeData.primaryColor),
        onConfirm: (Picker picker, List value) async {
          selectedLanguage =
              picker.getSelectedValues()[0].toString().toLowerCase();

          setState(() {
            isDialogOpen = false;
          });
        },
        onCancel: () => setState(() => isDialogOpen = false),
      ).show(scaffoldState.currentState);
    }
  }

  _switchLang(String newLang) async {
    if (newLang != null && newLang.isNotEmpty)
      await AppLocalizations.load(new Locale(newLang));

    widget.appState.language = newLang;
    this.language = newLang;
  }

  Widget settingsLoader() {
    return WillPopScope(
        onWillPop: () async {
          if (ModalRoute.of(context).settings.arguments is String &&
              ModalRoute.of(context).settings.arguments == "error.dialog") {
            RestartWidget.restartApp(context, shouldLoadConfig: false);
            return false;
          }
          return true;
        },
        child: CommonScaffold(
          showAppBar: widget.appState.appFrame == null ||
              widget.appState.appFrame.showScreenHeader,
          centerDocked: true,
          scaffoldKey: scaffoldState,
          appTitle: AppLocalizations.of(context).text('Settings'),
          showBottomNav: isDialogOpen != null && isDialogOpen ? false : true,
          showFAB: (!kIsWeb && !isDialogOpen),
          backGroundColor: (widget.appState.applicationStyle != null &&
                  widget.appState.applicationStyle?.desktopColor != null)
              ? widget.appState.applicationStyle?.desktopColor
              : Colors.grey.shade300,
          floatingIcon: FontAwesomeIcons.qrcode,
          qrCallback: () => scanBarcode(),
          bodyData: settingsBuilder(),
          bottomButton1: widget.warmWelcome
              ? null
              : AppLocalizations.of(context).text('Cancel').toUpperCase(),
          bottomButton2: widget.warmWelcome
              ? AppLocalizations.of(context).text('Open').toUpperCase()
              : AppLocalizations.of(context).text('Save').toUpperCase(),
          bottomButton1Function: () {
            if (!widget.warmWelcome) {
              if (ModalRoute.of(context).settings.arguments is String &&
                  ModalRoute.of(context).settings.arguments == "error.dialog") {
                RestartWidget.restartApp(context, shouldLoadConfig: false);
              } else {
                if (Navigator.of(context).canPop()) Navigator.of(context).pop();
              }
            }
          },
          bottomButton2Function: () {
            savePreferences();
            RestartWidget.restartApp(context, shouldLoadConfig: false);
          },
        ));
  }

  savePreferences() async {
    if (_checkString(this.appName) && _checkString(this.baseUrl)) {
      widget.manager.setAppData(
          appName: this.appName,
          baseUrl: this.baseUrl,
          language: this.language,
          picSize: widget.appState.picSize);

      widget.manager
          .setLoginData(username: null, password: null, override: true);
      widget.manager.setAuthKey(null);

      widget.manager.setSyncLoginData(username: null, password: null);

      widget.manager.setOfflineLoginHash(username: null, password: null);
    } else {
      showError(context, 'App name or base URL are null or empty',
          'Please enter a valid app name and base URL');
    }

    if (_checkString(toSaveUsername) && _checkString(toSavePwd))
      widget.manager
          .setLoginData(username: toSaveUsername, password: toSavePwd);

    if (widget.appState.language != this.selectedLanguage) {
      _switchLang(this.selectedLanguage);
    }
  }

  bool _checkString(String toCheck) {
    return (toCheck != null && toCheck.isNotEmpty);
  }

  Future scanBarcode() async {
    // var result = await FlutterBarcodeScanner.scanBarcode('${Theme.of(context).primaryColor.value}', 'Cancel', false, ScanMode.QR);
    // String barcodeResult = await FlutterBarcodeScanner.scanBarcode(
    //     "#ff6666", AppLocalizations.of(context).text("Cancel"), true, ScanMode.QR);

    var result = await BarcodeScanner.scan();

    Map<String, dynamic> properties = getProperties(result.rawContent);

    setState(() {
      if (properties['APPNAME'] != null) {
        widget.appState.appName = properties['APPNAME'];
        appName = properties['APPNAME'];
      } else {
        showError(context, 'QR Code Error',
            "Please scan a valid QR Code for the Settings");
      }
      if (properties['URL'] != null) {
        widget.appState.baseUrl = properties['URL'];
        baseUrl = properties['URL'];
      } else {
        showError(context, 'QR Code Error',
            "Please scan a valid QR Code for the Settings");
      }
      if (properties['USER'] != null && properties['PWD'] != null) {
        toSaveUsername = properties['USER'];
        toSavePwd = properties['PWD'];
      }
    });
  }

  Map<String, dynamic> getProperties(String barcodeResult) {
    Map<String, dynamic> properties = <String, dynamic>{};

    if (barcodeResult != null &&
        barcodeResult.isNotEmpty &&
        barcodeResult != '-1') {
      print(barcodeResult);
      List<String> result = barcodeResult.split('\n');

      properties['APPNAME'] = result[0].substring(result[0].indexOf(': ') + 2);

      properties['URL'] = result[1].substring(result[1].indexOf(': ') + 2);
    }

    return properties;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: settingsLoader(),
    );
  }
}
