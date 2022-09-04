import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';

import '../../mask/setting/settings_page.dart';

class SettingsLocation extends BeamLocation {
  @override
  List<BeamPage> buildPages(BuildContext context, RouteInformationSerializable state) {
    return [
      const BeamPage(
        key: ValueKey("Settings"),
        child: SettingsPage(),
      ),
    ];
  }

  @override
  List<Pattern> get pathPatterns => [
        '/settings',
      ];
}
