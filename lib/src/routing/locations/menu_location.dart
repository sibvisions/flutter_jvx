import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';

import '../../../flutter_jvx.dart';
import '../../../services.dart';
import '../../mask/menu/app_menu.dart';

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
        child: const AppMenu(),
      ),
    ];
  }

  @override
  List<Pattern> get pathPatterns => [
        '/menu',
      ];
}
