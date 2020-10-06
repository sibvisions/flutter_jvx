import 'dart:convert';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../logic/bloc/theme_bloc.dart';
import '../../ui/tools/restart.dart';
import '../../utils/shared_preferences_helper.dart';
import '../../ui/widgets/common_dialogs.dart';
import '../../ui/widgets/common_scaffold.dart';
import '../../utils/globals.dart' as globals;
import '../../utils/translations.dart';
import '../../utils/uidata.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key}) : super(key: key);

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

  String get versionText {
    String v = 'App v$version Build $buildNumber';
    if (globals.appVersion != null && globals.appVersion.isNotEmpty)
      v += '\nServer v${globals.appVersion}';

    return v;
  }

  String get imageSizeTitle {
    if (this.imageSizeItems == null) {
      this.imageSizeItems = [
        PickerItem<int>(
            text: Text(Translations.of(context)
                .text2('Small (320 px)', 'Small (320 px)')),
            value: 320),
        PickerItem<int>(
            text: Text(Translations.of(context)
                .text2('Medium (640 px)', 'Medium (640 px)')),
            value: 640),
        PickerItem<int>(
            text: Text(Translations.of(context)
                .text2('Big (1024 px)', 'Big (1024 px)')),
            value: 1024),
      ];
    }

    PickerItem<int> item = this
        .imageSizeItems
        .firstWhere((element) => element.value == globals.uploadPicWidth);
    if (item != null) return (item.text as Text).data;

    return "";
  }

  int get imageSizeIndex {
    return this
        .imageSizeItems
        .indexWhere((element) => element.value == globals.uploadPicWidth);
  }

  @override
  void initState() {
    super.initState();
    loadVersion();
  }

  Widget settingsBuilder() {
    return SingleChildScrollView(
      child: Theme(
        data: ThemeData(fontFamily: UIData.ralewayFont),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                Translations.of(context)
                    .text2('Application Settings', 'Application Settings'),
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
                      color: UIData.ui_kit_color_2,
                    ),
                    title: Text(
                        Translations.of(context).text2('App name', 'App name')),
                    trailing: FaIcon(FontAwesomeIcons.arrowRight),
                    subtitle:
                        Text(globals.appName != null ? globals.appName : ''),
                    onTap: () {
                      showTextInputDialog(
                          context,
                          Translations.of(context)
                              .text2('App name', 'App name'),
                          Translations.of(context)
                              .text2('App name', 'App name'),
                          Translations.of(context)
                              .text2('Enter new App Name', 'Enter App name'),
                          globals.appName, (String value) {
                        if (value == null)
                          this.appName = globals.appName;
                        else {
                          setState(() {
                            this.appName = value;
                            globals.appName = value;
                          });
                        }
                      });
                    },
                  ),
                  ListTile(
                    leading: FaIcon(
                      FontAwesomeIcons.keyboard,
                      color: UIData.ui_kit_color_2,
                    ),
                    title: Text(
                        Translations.of(context).text2('Base Url', 'Base Url')),
                    trailing: FaIcon(FontAwesomeIcons.arrowRight),
                    subtitle:
                        Text(globals.baseUrl != null ? globals.baseUrl : ''),
                    onTap: () {
                      showTextInputDialog(
                          context,
                          Translations.of(context)
                              .text2('Base Url', 'Base Url'),
                          Translations.of(context)
                              .text2('Base Url', 'Base Url'),
                          'http://enter.baseUrl/services/mobile',
                          globals.baseUrl, (String value) {
                        if (value == null)
                          this.baseUrl = globals.baseUrl;
                        else {
                          if (value.endsWith('/')) {
                            value = value.substring(0, value.length - 1);
                          }

                          setState(() {
                            this.baseUrl = value;
                            globals.baseUrl = value;
                          });
                        }
                      });
                    },
                  ),
                  ListTile(
                    leading: FaIcon(
                      FontAwesomeIcons.language,
                      color: UIData.ui_kit_color_2,
                    ),
                    title: Text(
                        Translations.of(context).text2('Language', 'Language')),
                    trailing: FaIcon(FontAwesomeIcons.arrowRight),
                    subtitle:
                        Text(globals.language != null ? globals.language : ''),
                    onTap: () {
                      showLanguagePicker(context);
                    },
                  ),
                  ListTile(
                    leading: FaIcon(
                      FontAwesomeIcons.image,
                      color: UIData.ui_kit_color_2,
                    ),
                    title: Text(this.imageSizeTitle),
                    trailing: FaIcon(FontAwesomeIcons.arrowRight),
                    onTap: () {
                      showImageSizePicker(context);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                Translations.of(context).text2('Version info', 'Version info'),
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
    Map<String, dynamic> buildversion = json.decode(await rootBundle.loadString(
        globals.package
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
      confirmText: Translations.of(context).text2('Confirm'),
      cancelText: Translations.of(context).text2('Cancel'),
      adapter: PickerDataAdapter(data: this.imageSizeItems),
      selecteds: selected,
      changeToFirst: true,
      textAlign: TextAlign.center,
      columnPadding: const EdgeInsets.all(8.0),
      confirmTextStyle: TextStyle(color: UIData.ui_kit_color_2),
      cancelTextStyle: TextStyle(color: UIData.ui_kit_color_2),
      onConfirm: (Picker picker, List value) {
        setState(() {
          isDialogOpen = false;

          globals.uploadPicWidth = picker.getSelectedValues()[0];
        });
      },
      onCancel: () => setState(() => isDialogOpen = false),
      onSelect: (picker, index, selecteds) =>
          setState(() => isDialogOpen = false),
    ).show(scaffoldState.currentState);
  }

  showLanguagePicker(BuildContext context) {
    List languages = globals.translation.keys
        .map((k) => k.replaceAll('translation_', '').replaceAll('.xml', ''))
        .toList();

    if (languages != null && languages.isNotEmpty)
      languages[languages.indexOf('translation')] = 'en';

    List<int> selected;
    int selectedIndex =
        languages.indexWhere((element) => element == globals.language);

    if (selectedIndex >= 0 && selectedIndex < languages.length)
      selected = [selectedIndex];

    setState(() {
      isDialogOpen = true;
    });

    new Picker(
            confirmText: Translations.of(context).text2('Confirm'),
            cancelText: Translations.of(context).text2('Cancel'),
            adapter: PickerDataAdapter<String>(pickerdata: languages),
            selecteds: selected,
            changeToFirst: true,
            textAlign: TextAlign.center,
            columnPadding: const EdgeInsets.all(8.0),
            confirmTextStyle: TextStyle(color: UIData.ui_kit_color_2),
            cancelTextStyle: TextStyle(color: UIData.ui_kit_color_2),
            onConfirm: (Picker picker, List value) {
              String newLang =
                  picker.getSelectedValues()[0].toString().toLowerCase();
              setState(() {
                isDialogOpen = false;

                globals.language = newLang;
                this.language = newLang;
                Translations.load(new Locale(newLang));
              });
            },
            onCancel: () => setState(() => isDialogOpen = false),
            onSelect: (Picker picker, int index, List<int> selected) =>
                setState(() => isDialogOpen = false))
        .show(scaffoldState.currentState);
  }

  Widget settingsLoader() {
    return WillPopScope(
        onWillPop: () async {
          if (ModalRoute.of(context).settings.arguments is String &&
              ModalRoute.of(context).settings.arguments == "error.dialog") {
            RestartWidget.restartApp(context, loadConf: false);
            return false;
          }
          return true;
        },
        child: CommonScaffold(
          showAppBar:
              globals.appFrame == null || globals.appFrame.showScreenHeader,
          centerDocked: true,
          scaffoldKey: scaffoldState,
          appTitle: Translations.of(context).text2('Settings', 'Settings'),
          showBottomNav: true,
          showFAB: (!kIsWeb && !isDialogOpen),
          backGroundColor: (globals.applicationStyle != null &&
                  globals.applicationStyle.desktopColor != null)
              ? globals.applicationStyle.desktopColor
              : Colors.grey.shade300,
          floatingIcon: FontAwesomeIcons.qrcode,
          qrCallback: () => scanBarcode(),
          bodyData: settingsBuilder(),
          bottomButton1:
              Translations.of(context).text2('Back', 'Back').toUpperCase(),
          bottomButton2: Translations.of(context)
              .text2('Restart', 'Restart')
              .toUpperCase(),
          bottomButton1Function: () {
            if (ModalRoute.of(context).settings.arguments is String &&
                ModalRoute.of(context).settings.arguments == "error.dialog") {
              RestartWidget.restartApp(context, loadConf: false);
            } else {
              Navigator.of(context).pop();
            }
          },
          bottomButton2Function: () {
            savePreferences();
            RestartWidget.restartApp(context, loadConf: false);
          },
        ));
  }

  savePreferences() async {
    SharedPreferencesHelper().setData(
        this.appName, this.baseUrl, this.language, globals.uploadPicWidth);
    SharedPreferencesHelper().setLoginData(toSaveUsername, toSavePwd);
  }

  Future scanBarcode() async {
    var result = await BarcodeScanner.scan();
    // String barcodeResult = await FlutterBarcodeScanner.scanBarcode(
    //     "#ff6666", Translations.of(context).text2("Cancel"), true, ScanMode.QR);

    Map<String, dynamic> properties = getProperties(result);

    setState(() {
      if (properties['APPNAME'] != null) {
        globals.appName = properties['APPNAME'];
        appName = properties['APPNAME'];
      } else {
        showError(context, 'QR Code Error',
            "Please scan a valid QR Code for the Settings");
      }
      if (properties['URL'] != null) {
        globals.baseUrl = properties['URL'];
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
    return BlocBuilder<ThemeBloc, ThemeData>(builder: (context, state) {
      return Container(
        child: settingsLoader(),
      );
    });
  }
}
