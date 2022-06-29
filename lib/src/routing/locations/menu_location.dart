import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/src/mask/menu/app_menu.dart';
import 'package:flutter_client/src/mixin/ui_service_getter_mixin.dart';

/// Displays all possible screens of the menu
class MenuLocation extends BeamLocation<BeamState> with UiServiceGetterMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    getUiService().setRouteContext(pContext: context);
    return [
      BeamPage(child: AppMenu(), key: const ValueKey("menu")),
    ];
  }

  @override
  List<Pattern> get pathPatterns => ['/menu'];
}
