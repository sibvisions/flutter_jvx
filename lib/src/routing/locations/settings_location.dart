import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

import '../../mask/setting/settings_page.dart';

class SettingsLocation extends BeamLocation {
  @override
  List<BeamPage> buildPages(BuildContext context, RouteInformationSerializable state) {
    return [BeamPage(key: UniqueKey(), child: const SettingsPage())];
  }

  @override
  List<Pattern> get pathPatterns => [
        '/setting',
      ];
}
