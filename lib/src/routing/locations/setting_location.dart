import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/src/mask/setting/settings_page.dart';

class SettingLocation extends BeamLocation {
  @override
  List<BeamPage> buildPages(BuildContext context, RouteInformationSerializable state) {
    return [const BeamPage(key: ValueKey("Setting"), child: SettingsPage())];
  }

  @override
  List<Pattern> get pathPatterns => [
        '/setting',
      ];
}
