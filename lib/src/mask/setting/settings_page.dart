import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  late SettingGroup baseSettings;

  late ValueNotifier<String> baseUrlNotifier;


  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {

    baseUrlNotifier = ValueNotifier<String>(configService.getUrl());

    baseSettings = _buildBaseSettings();
    super.initState();
  }

  @override
  void dispose() {
    baseUrlNotifier.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              baseSettings,
            ],
          ),
        ));
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  SettingGroup _buildBaseSettings(){


    SettingItem appNameSetting = SettingItem(
        frontIcon: const FaIcon(FontAwesomeIcons.server),
        endIcon: const FaIcon(FontAwesomeIcons.arrowRight),
        value: ValueNotifier("asd"),
        title: "App name",
        onPressed: () {},
    );

    SettingItem baseUrlSetting = SettingItem(
        frontIcon: const FaIcon(FontAwesomeIcons.globe),
        endIcon: const FaIcon(FontAwesomeIcons.arrowRight),
        value: baseUrlNotifier,
        title: "URL",
        onPressed: () {
          // Set Value
          configService.setUrl("asdasd");
          baseUrlNotifier.value = configService.getUrl();
        },
    );


    return SettingGroup(
      groupHeader: const Text("Settings"),
      items: [appNameSetting, baseUrlSetting],
    );
  }


}
