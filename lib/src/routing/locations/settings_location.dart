import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';

import '../../../flutter_jvx.dart';
import '../../../mixin/services.dart';
import '../../mask/setting/settings_page.dart';

class SettingsLocation extends BeamLocation with UiServiceMixin {
  @override
  List<BeamPage> buildPages(BuildContext context, RouteInformationSerializable state) {
    getUiService().getAppManager()?.onSettingPage();

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
