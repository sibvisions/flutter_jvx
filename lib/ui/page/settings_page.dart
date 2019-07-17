import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jvx_mobile_v3/services/shared_preferences/shared_preferences_helper.dart';
import 'package:jvx_mobile_v3/ui/widgets/common_dialogs.dart';
import 'package:jvx_mobile_v3/ui/widgets/common_scaffold.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;
import 'package:jvx_mobile_v3/utils/translations.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key}) : super(key: key);

  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final scaffoldState = GlobalKey<ScaffoldState>();
  String appName, baseUrl;

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
                Translations.of(context).text('settings_general'),
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
                    title: Text(Translations.of(context).text('settings_app_name')),
                    trailing: Icon(FontAwesomeIcons.arrowRight),
                    subtitle: Text(this.appName == null ? globals.appName : this.appName),
                    onTap: () {
                      showTextInputDialog(
                        context, 
                        Translations.of(context).text('settings_app_name'), 
                        Translations.of(context).text('settings_app_name'), 
                        Translations.of(context).text('settings_app_name_hint'),
                        globals.appName,
                        (String value) {
                          if (value == null) this.appName = globals.appName;
                          else this.appName = value; globals.appName = value;
                        }
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      FontAwesomeIcons.keyboard,
                      color: UIData.ui_kit_color_2,
                    ),
                    title: Text(Translations.of(context).text('settings_base_url')),
                    trailing: Icon(FontAwesomeIcons.arrowRight),
                    subtitle: Text(this.baseUrl == null ? globals.baseUrl : this.baseUrl),
                    onTap: () {
                      showTextInputDialog(
                        context,
                        Translations.of(context).text('settings_base_url'),
                        Translations.of(context).text('settings_base_url'),
                        Translations.of(context).text('settings_base_url_hint'),
                        globals.baseUrl,
                        (String value) {
                          if (value == null) this.baseUrl = globals.baseUrl;
                          else this.baseUrl = value; globals.baseUrl = value;
                        }
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      FontAwesomeIcons.language,
                      color: UIData.ui_kit_color_2,
                    ),
                    title: Text(Translations.of(context).text('settings_language')),
                    trailing: Icon(FontAwesomeIcons.arrowDown),
                    subtitle: Text(globals.language),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget settingsLoader() {
    return CommonScaffold(
      appTitle: Translations.of(context).text('settings'),
      showBottomNav: true,
      showFAB: false,
      backGroundColor: Colors.grey.shade300,
      bodyData: settingsBuilder(),
      bottomButton1: 'EXIT',
      bottomButton2: 'SAVE',
      bottomButton1Function: () {
        Navigator.of(context).pop();
      },
      bottomButton2Function: () {
        SharedPreferencesHelper().setAppName(this.appName.toString());
        SharedPreferencesHelper().setBaseUrl(this.baseUrl.toString());
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
       child: settingsLoader(),
    );
  }
}