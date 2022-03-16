import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_client/src/mask/setting/widgets/setting_group.dart';
import 'package:flutter_client/src/mask/setting/widgets/setting_item.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../mixin/ui_service_mixin.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with UiServiceMixin, ConfigServiceMixin {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Application settings
  late SettingGroup baseSettings;
  /// Baseurl notifier, will rebuild the value once changed
  late ValueNotifier<String> baseUrlNotifier;
  /// Language notifier, , will rebuild the value once changed
  late ValueNotifier<String> languageNotifier;
  /// App name notifier, will rebuild the value once changed
  late ValueNotifier<String> appNameNotifier;

  /// Version Info
  late SettingGroup versionInfo;
  /// Commit notifier
  late ValueNotifier<String> commitNotifier;
  /// App version notifier
  late ValueNotifier<String> appVersionNotifier;
  /// Build date notifier
  late ValueNotifier<String> buildDateNotifier;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {

    // Application setting
    baseUrlNotifier = ValueNotifier(configService.getUrl());
    appNameNotifier = ValueNotifier(configService.getAppName());
    languageNotifier = ValueNotifier("TODO");

    // Version Info
    // ToDo get real version info
    appVersionNotifier = ValueNotifier("0.5");
    commitNotifier = ValueNotifier("akV83k5");
    buildDateNotifier = ValueNotifier("16.03.2022");

    baseSettings = _buildApplicationSettings();
    versionInfo = _buildVersionInfo();
    super.initState();
  }

  @override
  void dispose() {
    baseUrlNotifier.dispose();
    languageNotifier.dispose();
    appNameNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          title: const Text("Settings"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              baseSettings,
              versionInfo
            ],
          ),
        ));
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  SettingGroup _buildApplicationSettings(){

    SettingItem appNameSetting = SettingItem(
        frontIcon: const FaIcon(FontAwesomeIcons.server),
        endIcon: const FaIcon(FontAwesomeIcons.arrowRight),
        value: appNameNotifier,
        title: "App name",
    );

    SettingItem baseUrlSetting = SettingItem(
        frontIcon: const FaIcon(FontAwesomeIcons.globe),
        endIcon: const FaIcon(FontAwesomeIcons.arrowRight),
        value: baseUrlNotifier,
        title: "URL",
    );

    SettingItem languageSetting = SettingItem(
        frontIcon: const FaIcon(FontAwesomeIcons.language),
        endIcon: const FaIcon(FontAwesomeIcons.arrowRight),
        value: languageNotifier,
        title: "Language",
    );

    return SettingGroup(
      groupHeader: const Padding(
        padding: EdgeInsets.fromLTRB(10,0,0,0),
        child: Text("Application",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      items: [appNameSetting, baseUrlSetting, languageSetting],
    );
  }

  SettingGroup _buildVersionInfo() {

    SettingItem commitSetting = SettingItem(
      frontIcon: const FaIcon(FontAwesomeIcons.codeBranch),
      value: commitNotifier,
      title: "Github commit",
    );

    SettingItem appVersionSetting = SettingItem(
      frontIcon: const FaIcon(FontAwesomeIcons.github),
      value: appVersionNotifier,
      title: "App version",
    );

    SettingItem buildDataSetting = SettingItem(
      frontIcon: const FaIcon(FontAwesomeIcons.calendar),
      value: buildDateNotifier,
      title: "Build date",
    );


    SettingGroup group = SettingGroup(
        groupHeader: const Padding(
          padding: EdgeInsets.fromLTRB(10,0,0,0),
          child: Text("Version Info",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        items: [commitSetting, appVersionSetting, buildDataSetting]
    );

    return group;
  }


}
