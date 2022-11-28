import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';

import '../../flutter_jvx.dart';
import '../../mask/setting/settings_page.dart';
import '../../service/ui/i_ui_service.dart';

class SettingsLocation extends BeamLocation {
  @override
  List<BeamPage> buildPages(BuildContext context, RouteInformationSerializable state) {
    IUiService().getAppManager()?.onSettingPage();

    return [
      BeamPage(
        title: FlutterJVx.translate("Settings"),
        key: const ValueKey("Settings"),
        child: const SettingsPage(),
      ),
    ];
  }

  @override
  List<Pattern> get pathPatterns => [
        '/settings',
      ];
}
