import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jvx_mobile_v3/model/language.dart';
import 'package:jvx_mobile_v3/ui/tools/restart.dart';
import 'package:jvx_mobile_v3/utils/shared_preferences_helper.dart';
import 'package:jvx_mobile_v3/ui/widgets/common_dialogs.dart';
import 'package:jvx_mobile_v3/ui/widgets/common_scaffold.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;
import 'package:jvx_mobile_v3/utils/translations.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';
import 'package:flutter_picker/flutter_picker.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key}) : super(key: key);

  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final scaffoldState = GlobalKey<ScaffoldState>();
  String appName, baseUrl, language;

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
                Translations.of(context).text2('settings_general', 'General Settings'),
                style: TextStyle(color: Colors.grey.shade700),
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
                    title: Text(Translations.of(context).text2('settings_app_name', 'App name')),
                    trailing: Icon(FontAwesomeIcons.arrowRight),
                    subtitle: Text(this.appName == null ? globals.appName : this.appName),
                    onTap: () {
                      showTextInputDialog(
                        context, 
                        Translations.of(context).text2('settings_app_name', 'App name'),
                        Translations.of(context).text2('settings_app_name', 'App name'),
                        Translations.of(context).text2('settings_app_name_hint', 'Enter App name'),
                        globals.appName,
                        (String value) {
                          if (value == null) this.appName = globals.appName;
                          else { this.appName = value; globals.appName = value; }
                        }
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      FontAwesomeIcons.keyboard,
                      color: UIData.ui_kit_color_2,
                    ),
                    title: Text(Translations.of(context).text2('settings_base_url', 'Base Url')),
                    trailing: Icon(FontAwesomeIcons.arrowRight),
                    subtitle: Text(this.baseUrl == null ? globals.baseUrl : this.baseUrl),
                    onTap: () {
                      showTextInputDialog(
                        context,
                        Translations.of(context).text2('settings_base_url', 'Base Url'),
                        Translations.of(context).text2('settings_base_url', 'Base Url'),
                        Translations.of(context).text2('settings_base_url_hint', 'Enter Base Url'),
                        globals.baseUrl,
                        (String value) {
                          if (value == null) this.baseUrl = globals.baseUrl;
                          else {
                            if (value.endsWith('/')) {
                              value = value.substring(0, value.length - 1);
                            }

                            this.baseUrl = value; globals.baseUrl = value;
                          }
                        }
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      FontAwesomeIcons.language,
                      color: UIData.ui_kit_color_2,
                    ),
                    title: Text(Translations.of(context).text2('settings_language', 'Language')),
                    trailing: Icon(FontAwesomeIcons.arrowDown),
                    subtitle: Text(this.language == null ? globals.language : this.language),
                    onTap: () {
                      showLanguagePicker(context);
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  showLanguagePicker(BuildContext context) {
    List languages 
      = globals.translation.keys.map((k) => k.replaceAll('translation_', '').replaceAll('.xml', '')).toList();

    languages.remove('translation');

    new Picker(
      adapter: PickerDataAdapter<String>(pickerdata: languages),
      changeToFirst: true,
      textAlign: TextAlign.center,
      columnPadding: const EdgeInsets.all(8.0),
      confirmTextStyle: TextStyle(
        color: UIData.ui_kit_color_2
      ),
      cancelTextStyle: TextStyle(
        color: UIData.ui_kit_color_2
      ),
      onConfirm: (Picker picker, List value) {
        String newLang = picker.getSelectedValues()[0].toString().toLowerCase();
        setState(() {
          globals.language = newLang;
          this.language = newLang;
          Translations.load(new Locale(newLang));
        });
      }
    ).show(scaffoldState.currentState);
  }

  Widget settingsLoader() {
    return CommonScaffold(
      scaffoldKey: scaffoldState,
      appTitle: Translations.of(context).text2('Settings', 'Settings'),
      showBottomNav: true,
      showFAB: false,
      backGroundColor: Colors.grey.shade300,
      bodyData: settingsBuilder(),
      bottomButton1: Translations.of(context).text2('Exit', 'Exit').toUpperCase(),
      bottomButton2: Translations.of(context).text2('Save', 'Save').toUpperCase(),
      bottomButton1Function: () {
        Navigator.of(context).pop();
      },
      bottomButton2Function: () {
        savePreferences();
        RestartWidget.restartApp(context);
      },
    );
  }

  savePreferences() async {
    SharedPreferencesHelper().setData(this.appName, this.baseUrl, this.language);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
       child: settingsLoader(),
    );
  }
}