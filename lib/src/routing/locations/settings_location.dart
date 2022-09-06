import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';

import '../../../mixin/ui_service_mixin.dart';
import '../../mask/setting/settings_page.dart';

class SettingsLocation extends BeamLocation with UiServiceGetterMixin {
  @override
  List<BeamPage> buildPages(BuildContext context, RouteInformationSerializable state) {
    getUiService().getAppManager()?.onSettingPage();

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
