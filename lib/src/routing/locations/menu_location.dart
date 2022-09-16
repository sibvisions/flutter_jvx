import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';

import '../../../flutter_jvx.dart';
import '../../../mixin/config_service_mixin.dart';
import '../../../mixin/ui_service_mixin.dart';
import '../../mask/frame/frame.dart';
import '../../mask/menu/app_menu.dart';

/// Displays all possible screens of the menu
class MenuLocation extends BeamLocation<BeamState> with ConfigServiceGetterMixin, UiServiceGetterMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    String sValue = "Menu_${getConfigService().isOffline() ? "offline" : "online"}";

    getUiService().getAppManager()?.onMenuPage();

    return [
      BeamPage(
        title: FlutterJVx.translate("Menu"),
        //Append state to trigger rebuild on online/offline switch
        key: ValueKey(sValue),
        child: Frame.wrapWithFrame(
          forceWeb: getConfigService().isWebOnly(),
          forceMobile: getConfigService().isMobileOnly(),
          builder: (context) => AppMenu(),
        ),
      ),
    ];
  }

  @override
  List<Pattern> get pathPatterns => [
        '/menu',
      ];
}
