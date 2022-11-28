import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';

import '../../flutter_jvx.dart';
import '../../mask/menu/menu_page.dart';
import '../../service/ui/i_ui_service.dart';

/// Displays all possible screens of the menu
class MenuLocation extends BeamLocation<BeamState> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    IUiService().getAppManager()?.onMenuPage();

    return [
      BeamPage(
        title: FlutterJVx.translate("Menu"),
        key: const ValueKey("Menu"),
        child: const MenuPage(),
      ),
    ];
  }

  @override
  List<Pattern> get pathPatterns => [
        '/menu',
      ];
}
