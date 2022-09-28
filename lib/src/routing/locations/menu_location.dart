import 'package:beamer/beamer.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../../flutter_jvx.dart';
import '../../../services.dart';
import '../../mask/frame/frame.dart';
import '../../mask/menu/app_menu.dart';

/// Displays all possible screens of the menu
class MenuLocation extends BeamLocation<BeamState> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    if (initialPath != null) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        context.beamToNamed(initialPath!);
        initialPath = null;
      });
    } else {
      IUiService().getAppManager()?.onMenuPage();
    }

    String sValue = "Menu_${IConfigService().isOffline() ? "offline" : "online"}";

    return [
      BeamPage(
        title: FlutterJVx.translate("Menu"),
        //Append state to trigger rebuild on online/offline switch
        key: ValueKey(sValue),
        child: Frame.wrapWithFrame(
          forceWeb: IConfigService().isWebOnly(),
          forceMobile: IConfigService().isMobileOnly(),
          builder: (context) => const AppMenu(),
        ),
      ),
    ];
  }

  @override
  List<Pattern> get pathPatterns => [
        '/menu',
      ];
}
