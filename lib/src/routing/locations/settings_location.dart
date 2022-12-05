import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';

import '../../flutter_ui.dart';
import '../../mask/setting/settings_page.dart';
import '../../service/ui/i_ui_service.dart';

class SettingsLocation extends BeamLocation {
  @override
  List<BeamPage> buildPages(BuildContext context, RouteInformationSerializable state) {
    IUiService().getAppManager()?.onSettingPage();

    return [
      BeamPage(
        title: FlutterUI.translate("Settings"),
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
