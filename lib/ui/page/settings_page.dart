import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:package_info/package_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
  String appName, baseUrl, language, version;
  String toSaveUsername;
  String toSavePwd;
  List<PickerItem<int>> imageSizeItems;

  String get versionText {
    String v = 'App V $version';
    if (globals.appVersion != null && globals.appVersion.isNotEmpty)
      v += ', Server V ${globals.appVersion}';

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
      return this.imageSizeItems.indexWhere((element) => element.value==globals.uploadPicWidth);
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
                    leading: Icon(
                      FontAwesomeIcons.server,
                      color: UIData.ui_kit_color_2,
                    ),
                    title: Text(
                        Translations.of(context).text2('App name', 'App name')),
                    trailing: Icon(FontAwesomeIcons.arrowRight),
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
                    leading: Icon(
                      FontAwesomeIcons.keyboard,
                      color: UIData.ui_kit_color_2,
                    ),
                    title: Text(
                        Translations.of(context).text2('Base Url', 'Base Url')),
                    trailing: Icon(FontAwesomeIcons.arrowRight),
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
                    leading: Icon(
                      FontAwesomeIcons.language,
                      color: UIData.ui_kit_color_2,
                    ),
                    title: Text(
                        Translations.of(context).text2('Language', 'Language')),
                    trailing: Icon(FontAwesomeIcons.arrowRight),
                    subtitle:
                        Text(globals.language != null ? globals.language : ''),
                    onTap: () {
                      showLanguagePicker(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      FontAwesomeIcons.image,
                      color: UIData.ui_kit_color_2,
                    ),
                    title: Text(this.imageSizeTitle),
                    trailing: Icon(FontAwesomeIcons.arrowRight),
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
                    leading: Icon(
                      FontAwesomeIcons.codeBranch,
                    ),
                    title: Text(versionText),
                  )
                ]))
          ],
        ),
      ),
    );
  }

  loadVersion() {
    PackageInfo.fromPlatform().then((val) {
      setState(() {
        version = val.version;
      });
    });
  }

  showImageSizePicker(BuildContext context) {

    List<int> selected;
    if (this.imageSizeIndex>=0 && this.imageSizeIndex<this.imageSizeItems.length)
      selected = [this.imageSizeIndex];

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
            globals.uploadPicWidth = picker.getSelectedValues()[0];
          });
        }).show(scaffoldState.currentState);
  }

  showLanguagePicker(BuildContext context) {
    List languages = globals.translation.keys
        .map((k) => k.replaceAll('translation_', '').replaceAll('.xml', ''))
        .toList();

    if (languages != null && languages.isNotEmpty)
      languages[languages.indexOf('translation')] = 'en';

    List<int> selected;
    int selectedIndex =  languages.indexWhere((element) => element == globals.language);

    if (selectedIndex>=0 && selectedIndex<languages.length)
      selected = [selectedIndex];

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
            globals.language = newLang;
            this.language = newLang;
            Translations.load(new Locale(newLang));
          });
        }).show(scaffoldState.currentState);
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
          centerDocked: true,
          scaffoldKey: scaffoldState,
          appTitle: Translations.of(context).text2('Settings', 'Settings'),
          showBottomNav: true,
          showFAB: true,
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
    var options = ScanOptions(restrictFormat: [
      BarcodeFormat.qr
    ], strings: {
      "cancel": Translations.of(context).text2("Cancel"),
      "flash_on": Translations.of(context).text2("Flash on"),
      "flash_off": Translations.of(context).text2("Flash off"),
    });
    var result = await BarcodeScanner.scan(options: options);
    // String barcodeResult = await FlutterBarcodeScanner.scanBarcode(
    //     "#ff6666", Translations.of(context).text2("Cancel"), true, ScanMode.QR);

    Map<String, dynamic> properties = getProperties(result.rawContent);

    setState(() {
      if (properties['APPNAME'] != null) {
        globals.appName = properties['APPNAME'];
        appName = properties['APPNAME'];
      }
      if (properties['URL'] != null) {
        globals.baseUrl = properties['URL'];
        baseUrl = properties['URL'];
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
